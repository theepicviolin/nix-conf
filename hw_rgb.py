import time
import signal
import sys
import logging
import openrgb
from openrgb import OpenRGBClient
from openrgb.utils import RGBColor, DeviceType
import psutil
import numpy as np


# Set up logging to systemd journal
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

std_handler = logging.StreamHandler(sys.stdout)
std_handler.setFormatter(logging.Formatter("[%(levelname)s] %(message)s"))
logger.addHandler(std_handler)

is_sleeping = False
red = RGBColor(255, 0, 0)
black = RGBColor(0, 0, 0)


def rotate(colors, offset):
    return colors[offset:] + colors[:offset]


def handle_sleep(sleeping):
    global is_sleeping
    is_sleeping = sleeping
    if sleeping:
        mobo.set_color(
            black, True
        )  # Turn off everything quickly before the system sleeps
        client.clear()
        logger.info("About to sleep")
    else:
        logger.info("About to wake")


def stop(*args):
    mobo.set_color(black, True)  # doesn't work reliably without this for some reason
    mobo.set_color(black, False)
    logger.info("Exiting")
    args_str = ",".join(map(str, args))
    logger.info(args_str)
    client.clear()
    client.disconnect()
    sys.exit(0)


def setup():
    try:
        client = OpenRGBClient()
        logger.info("Connected to OpenRGB server")

        client.clear()  # Turns everything off

        mobo = client.get_devices_by_type(DeviceType.MOTHERBOARD)[0]
        fan_bottom = mobo.zones[0]
        fan_top = mobo.zones[1]
        mobo_zone = mobo.zones[2]

        mobo.set_mode("direct")

        fan_bottom.resize(12)
        fan_top.resize(12)
        mobo_zone.resize(8)

        for i in range(12):
            fan_bottom.leds[i].name = f"Bottom {i+1}:00"
            fan_top.leds[i].name = f"Top {((i+6) % 12) + 1}:00"
    except ConnectionRefusedError:
        return False, None, None, None, None, None

    return True, client, mobo, fan_bottom, fan_top, mobo_zone


def get_colors(phase_cpu, phase_gpu):
    gputimeout = 10
    waittime = 0
    while "amdgpu" not in psutil.sensors_temperatures():
        time.sleep(0.1)
        waittime += 0.1
        if waittime > gputimeout:
            logger.error("Timeout waiting for GPU temperature sensor")
            return RGBColor(0, 0, 0), RGBColor(0, 0, 0), phase_cpu, phase_gpu
    gputemp = psutil.sensors_temperatures()["amdgpu"][0].current
    cputemp = psutil.sensors_temperatures()["gigabyte_wmi"][2].current
    gpufan = psutil.sensors_fans()["amdgpu"][0].current

    dtheta = np.pi / 100

    # get CPU color
    h_cpu = max(cputemp - 50, 0)
    v_cpu = (1 - abs(np.cos(phase_cpu))) * 100
    color_cpu = RGBColor.fromHSV(h_cpu, 100, v_cpu)

    # get GPU color
    h_gpu = max(gputemp - 55, 0)
    v_gpu = (1 - abs(np.cos(phase_gpu))) * 100
    color_gpu = RGBColor.fromHSV(h_gpu, 100, v_gpu)

    # update CPU phase
    speed_cpu = 1
    phase_cpu += speed_cpu * dtheta
    phase_cpu = phase_cpu % np.pi

    # update GPU phase
    speed_gpu = 1 + max((gpufan - 900) / 900, 0)
    phase_gpu += speed_gpu * dtheta
    phase_gpu = phase_gpu % np.pi

    # Line up timing (phase) of GPU and CPU breathing if the speed is the same
    if speed_gpu == speed_cpu:
        if abs(phase_gpu - phase_cpu) < 0.1:
            phase_gpu = phase_cpu
        else:
            phase_gpu += 0.05

    return color_cpu, color_gpu, phase_cpu, phase_gpu

signal.signal(signal.SIGINT, stop)
signal.signal(signal.SIGTERM, stop)

sleep_time = 1
connected = False
phase_cpu = 0
phase_gpu = 0
while True:
    try:
        if not connected:
            connected, client, mobo, fan_bottom, fan_top, mobo_zone = setup()
        if not connected:
            logger.info(
                "Connection refused, retrying in %d second%s...",
                sleep_time,
                "s" if sleep_time != 1 else "",
            )
            time.sleep(sleep_time)
            sleep_time = min(sleep_time * 2, 15)
            continue

        sleep_time = 1  # Reset sleep time on successful connection
        if is_sleeping:
            logger.info("System is sleeping")
            client.clear()
            phase_cpu = 0
            phase_gpu = 0
            time.sleep(1)
            continue

        color_cpu, color_gpu, phase_cpu, phase_gpu = get_colors(phase_cpu, phase_gpu)
        mobo.set_colors([color_gpu] * 12 + [color_cpu] * 12 + [red] * 8, True)
        time.sleep(0.01)
    except openrgb.utils.OpenRGBDisconnected as e:
        logger.info("Connection lost, reconnecting...")
        connected = False
    except KeyboardInterrupt:
        break

stop()
