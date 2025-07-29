import sys
import asyncio
from playwright.async_api import async_playwright

async def main():
    if len(sys.argv) < 2:
        print("Usage: python3 fetch_html.py <URL>")
        sys.exit(1)

    url = sys.argv[1]

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False, slow_mo=50)  # ❗ Headed mode
        context = await browser.new_context()
        page = await context.new_page()

        try:
            response = await page.goto(
              url,
              timeout=60_000,
              wait_until="domcontentloaded"    # ← faster than networkidle
            )
            await page.mouse.move(100, 100)
            await page.keyboard.press("PageDown")
            await page.screenshot(path="page.png", full_page=True)
            html = await page.content()
            print(html)
        finally:
            await browser.close()

if __name__ == "__main__":
    asyncio.run(main())
