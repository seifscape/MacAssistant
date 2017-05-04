//
//  AppDelegate.swift
//  MacAssistant
//
//  Created by Vansh on 4/27/17.
//  Copyright © 2017 vanshgandhi. All rights reserved.
//

import Cocoa
import OAuthSwift
import gRPC
import WebKit
import Magnet
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    let popover = NSPopover()
    let userDefaults = UserDefaults.standard
    var isLoggedIn: Bool {
        get {
            return userDefaults.bool(forKey: Constants.LOGGED_IN_KEY)
        }
        
        set {
            userDefaults.set(newValue, forKey: Constants.LOGGED_IN_KEY)
        }
    }
    
    public override init() {
        super.init()
        registerHotkey()
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        if isLoggedIn {
            // TODO: Check expiration time, then refresh access token
        }
        let viewController = isLoggedIn ? AssistantViewController(nibName: "AssistantView", bundle: nil) : LoginViewController(nibName: "LoginView", bundle: nil)
        popover.contentViewController = viewController
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let icon = #imageLiteral(resourceName: "statusIcon")
        icon.isTemplate = true
        statusItem.image = icon
        statusItem.action = #selector(statusIconClicked)
    }
    
    func notifyLoggedIn() {
        let controller = AssistantViewController(nibName: "AssistantView", bundle: nil)
        popover.contentViewController = controller
    }
    
    func registerHotkey() {
        guard let keyCombo = KeyCombo(doubledCocoaModifiers: .control) else { return }
        let hotKey = HotKey(identifier: "ControlDoubleTap",
                             keyCombo: keyCombo,
                             target: self,
                             action: #selector(AppDelegate.hotkeyPressed))
        hotKey.register()
    }
    
    func hotkeyPressed(sender: AnyObject?) {
        if (!popover.isShown) {
            showPopover(sender: sender)
        }
        
        if (isLoggedIn) {
//            (popover.contentViewController as? AssistantViewController).start()
        }
    }
    
    func statusIconClicked(sender: AnyObject?) {
        togglePopover(sender: sender)
    }
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // We don't call shutdown() here because we can't be sure that
        // any running server queues will have stopped by the time this is
        // called. If one is still running after we call shutdown(), the
        // program will crash.
        // gRPC.shutdown()
        HotKeyCenter.shared.unregisterAll()
    }


}
