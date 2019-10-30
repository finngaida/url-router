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
    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.menu = statusMenu
        statusItem.button?.image = NSImage(named: NSImage.Name("menuIcon"))
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

    @IBAction func showWindow(_ sender: Any) {
        guard let window = self.window ?? (NSStoryboard.main?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("mainWindow")) as? NSWindowController)?.window else { return }
        window.makeKeyAndOrderFront(self)
        window.makeMain()
    }
}

class WindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        (NSApplication.shared.delegate as? AppDelegate)?.window = self.window
    }
}
