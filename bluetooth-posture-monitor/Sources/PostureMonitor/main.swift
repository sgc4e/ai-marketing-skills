import Foundation
import CoreMotion

if #available(macOS 12.0, *) {
    let app = PostureMonitorApp()
    app.run()
} else {
    fputs("Error: macOS 12.0 or later is required\n", stderr)
    exit(1)
}
