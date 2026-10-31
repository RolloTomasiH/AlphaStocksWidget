#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AlphaStocks Desktop Widget Host Application
Native macOS Desktop Widget for Stock Market Monitoring
"""

import os
import sys
import json
import threading
import time
import webview
import AppKit
import Quartz
from market_service import MarketService, load_config, save_config, normalize_symbol

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
HTML_PATH = os.path.join(BASE_DIR, "web", "index.html")

SIZE_MAP = {
    "medium": (360, 180),
    "large": (360, 390),
    "extra_large": (740, 390)
}

class WidgetAPI:
    def __init__(self, service: MarketService, app_host):
        self.service = service
        self.host = app_host

    def get_data(self):
        return self.service.get_full_payload()

    def set_size(self, payload):
        size = payload.get("size", "large")
        cfg = load_config()
        cfg["size"] = size
        save_config(cfg)
        self.host.apply_window_size(size)
        return {"status": "ok", "size": size}

    def set_color(self, payload):
        scheme = payload.get("color_scheme", "china")
        cfg = load_config()
        cfg["color_scheme"] = scheme
        save_config(cfg)
        return {"status": "ok", "color_scheme": scheme}

    def set_interval(self, payload):
        interval = int(payload.get("refresh_interval", 5))
        cfg = load_config()
        cfg["refresh_interval"] = interval
        save_config(cfg)
        return {"status": "ok", "refresh_interval": interval}

    def set_window_level(self, payload):
        level_mode = payload.get("window_level", "desktop")
        cfg = load_config()
        cfg["window_level"] = level_mode
        save_config(cfg)
        self.host.apply_window_level(level_mode)
        return {"status": "ok", "window_level": level_mode}

    def add_stock(self, payload):
        code = str(payload.get("code", "")).strip().upper()
        if not code:
            return {"status": "error", "msg": "Empty code"}

        cfg = load_config()
        watchlist = cfg.get("watchlist", [])

        # 检查是否已存在
        for item in watchlist:
            if item.get("code") == code:
                return {"status": "exists", "msg": "Already in watchlist"}

        # 自动识别市场与名称
        market = "us"
        name = code
        if code.isdigit():
            if len(code) == 6:
                market = "sh" if code.startswith(("60", "68", "90")) else "sz"
            elif len(code) == 5:
                market = "hk"

        # 尝试通过接口拉取真实股票名称
        try:
            sym = normalize_symbol(code)
            res = self.service.fetch_stocks([{"code": code, "market": market, "name": code}])
            if res and res[0]["name"] != code:
                name = res[0]["name"]
        except Exception:
            pass

        watchlist.append({"code": code, "market": market, "name": name})
        cfg["watchlist"] = watchlist
        save_config(cfg)
        return {"status": "ok", "added": {"code": code, "name": name}}

    def remove_stock(self, payload):
        code = str(payload.get("code", "")).strip().upper()
        cfg = load_config()
        watchlist = cfg.get("watchlist", [])
        cfg["watchlist"] = [item for item in watchlist if item.get("code") != code]
        save_config(cfg)
        return {"status": "ok", "removed": code}

    def handle_action(self, action, payload=None):
        payload = payload or {}
        func = getattr(self, action, None)
        if callable(func):
            return func(payload) if payload else func()
        return {"error": f"Unknown action: {action}"}


class AlphaStocksApp:
    def __init__(self):
        self.service = MarketService()
        self.config = load_config()
        self.window = None
        self.api = WidgetAPI(self.service, self)

    def run(self):
        size_key = self.config.get("size", "large")
        width, height = SIZE_MAP.get(size_key, (360, 375))

        # 计算初始屏幕坐标
        pos = self.config.get("window_pos", None)
        x, y = 100, 100
        if pos and len(pos) == 2:
            x, y = pos[0], pos[1]
        else:
            # 默认停靠在右上角
            try:
                screen = AppKit.NSScreen.mainScreen()
                if screen:
                    frame = screen.visibleFrame()
                    x = int(frame.origin.x + frame.size.width - width - 40)
                    y = int(frame.origin.y + frame.size.height - height - 40)
            except Exception:
                pass

        self.window = webview.create_window(
            title="AlphaStocks Widget",
            url=f"file://{HTML_PATH}",
            width=width,
            height=height,
            x=x,
            y=y,
            frameless=True,
            easy_drag=True,
            on_top=False,
            transparent=True,
            js_api=self.api
        )

        # 启动后原生配置
        webview.start(self._configure_native_window, debug=False)

    def _configure_native_window(self):
        time.sleep(0.4)
        if not self.window or not hasattr(self.window, "native"):
            return

        ns_window = self.window.native

        def setup():
            try:
                # 1. 无边框与完全透明背景
                ns_window.setOpaque_(False)
                ns_window.setBackgroundColor_(AppKit.NSColor.clearColor())
                ns_window.setHasShadow_(True)
                ns_window.setMovableByWindowBackground_(True)

                # 2. 空间行为: 跨所有虚拟桌面常驻、不参与窗口切换循环
                collection_behavior = (
                    AppKit.NSWindowCollectionBehaviorCanJoinAllSpaces |
                    AppKit.NSWindowCollectionBehaviorStationary |
                    AppKit.NSWindowCollectionBehaviorIgnoresCycle
                )
                ns_window.setCollectionBehavior_(collection_behavior)

                # 3. 设置窗口层级
                level_mode = self.config.get("window_level", "desktop")
                self.apply_window_level(level_mode)

                print(f"[AlphaStocks] Native window initialized. Level: {level_mode}")
            except Exception as e:
                print(f"[AlphaStocks] Setup error: {e}")

        # 在主线程调度
        AppKit.NSOperationQueue.mainQueue().addOperationWithBlock_(setup)

        # 启动后台线程监听窗口位置变化并保存
        threading.Thread(target=self._monitor_position, daemon=True).start()

    def apply_window_level(self, level_mode: str):
        if not self.window or not hasattr(self.window, "native"):
            return
        ns_window = self.window.native

        def update():
            try:
                if level_mode == "desktop":
                    # 紧贴桌面壁纸层 (相当于原生桌面小组件)
                    # 使用 Quartz.kCGDesktopIconWindowLevel 或 kCGDesktopWindowLevel + 1
                    target_level = Quartz.kCGDesktopIconWindowLevel
                    ns_window.setLevel_(target_level)
                    ns_window.orderBack_(None)
                else:
                    # 悬浮顶层 HUD 模式
                    ns_window.setLevel_(AppKit.NSFloatingWindowLevel)
                    ns_window.orderFront_(None)
            except Exception as e:
                print(f"Error applying window level: {e}")

        AppKit.NSOperationQueue.mainQueue().addOperationWithBlock_(update)

    def apply_window_size(self, size_key: str):
        if not self.window or not hasattr(self.window, "native"):
            return
        width, height = SIZE_MAP.get(size_key, (360, 375))
        ns_window = self.window.native

        def resize():
            try:
                frame = ns_window.frame()
                new_x = frame.origin.x
                # 保持顶部对齐
                new_y = frame.origin.y + (frame.size.height - height)
                new_frame = AppKit.NSMakeRect(new_x, new_y, width, height)
                ns_window.setFrame_display_animate_(new_frame, True, True)
            except Exception as e:
                print(f"Error resizing window: {e}")

        AppKit.NSOperationQueue.mainQueue().addOperationWithBlock_(resize)

    def _monitor_position(self):
        last_pos = None
        while True:
            time.sleep(2.0)
            if not self.window or not hasattr(self.window, "native"):
                continue
            try:
                frame = self.window.native.frame()
                curr_pos = [int(frame.origin.x), int(frame.origin.y)]
                if curr_pos != last_pos:
                    last_pos = curr_pos
                    cfg = load_config()
                    cfg["window_pos"] = curr_pos
                    save_config(cfg)
            except Exception:
                pass

if __name__ == "__main__":
    app = AlphaStocksApp()
    app.run()
