#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = [
#   "pyppeteer"
# ]
# ///
import asyncio
import argparse
import base64
import os
import tempfile
from pyppeteer import launch

def parse_arguments():
    parser = argparse.ArgumentParser(description="Take a screenshot of the specified URL.")
    parser.add_argument('--url', required=True, help='The URL of the webpage to screenshot')
    parser.add_argument('--path', help='The path to save the screenshot')
    parser.add_argument('--fullpage', action='store_true', help='Whether to take a full-page screenshot')
    return parser.parse_args()

async def take_screenshot(page, path: str, full_page: bool = False):
    return await page.screenshot({"path": path, "fullPage": full_page})

async def main(url, path, full_page):
    # Launch a browser
    browser = await launch()

    # Open a new page
    page = await browser.newPage()

    # Navigate to the specified webpage using the URL argument
    await page.goto(url)

    if path:
        # Take a screenshot at specified path
        await take_screenshot(page, path, full_page)
    else:
        # Create a temporary file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".png") as temp_file:
            temp_path = temp_file.name

        # Take a screenshot at the temporary path
        await take_screenshot(page, temp_path, full_page)

        # Convert the screenshot to a base64 data URL
        with open(temp_path, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
        os.remove(temp_path)  # Remove the temporary file

        # Create the data URL
        data_url = f"data:image/png;base64,{encoded_string}"
        print(data_url)

    # Close the browser
    await browser.close()

if __name__ == "__main__":
    args = parse_arguments()
    asyncio.run(main(args.url, args.path, args.fullpage))
