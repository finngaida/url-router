//
//  AppDelegate.swift
//  URL Ruler
//
//  Created by Finn Gaida on 29.10.19.
//  Copyright © 2019 Finn Gaida. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var statusMenu: NSMenu!
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.menu = statusMenu
        statusItem.button?.title = "Ruler"
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        do {
            try Routing.shared.execute(urls)
        } catch let error {
            print(error)
        }
    }
}

