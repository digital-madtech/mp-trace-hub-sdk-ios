Steps to integrate MagicPixelTraceHub in iOS app:

1. Import the MagicPixel-services.plist file into your iOS project bundle.

2. MagicPixel-services.plist file should have the following properties configured.	
	API_KEY=YourAPIKey
	VENDOR_ID=YourVendorID
	PROJECT_ID=YourProjectId
	CLIENT_CODE=YourCompanyClientCode
	
	All these values would be provided by MPTraceHub team.

3. Before using any SDK features, add the following line in application's AppDelegate file.
    -   In your application's AppDelegate, configure MagicPixelTraceHub. This should be done only once in your application life cycle.
	MagicPixelTraceHub.shared.configure { (response) in            
        }

    -   Get the debug session id that will be used to view logs from a MP web session.
        let debugId = MagicPixelTraceHub.shared.debugId()
        Your application is responsible to expose the debugId to you so that you can use it to view the log session.

4.  To enable/disable console log collection, do the following.
    -   Start the log collection session.
	MagicPixelTraceHub.shared.startLogCollector { (response) in
	}

    -   When you are done, you can stop log collection as follows.
	MagicPixelTraceHub.shared.stopLogCollector { (response) in
	}

5.  To send logs with tags, do the following.
	
	MagicPixelTraceHub.shared.log(message: "<LOG HERE>", tag: "<TAG HERE>")

6. To collect WKWebView requests, do the following.

	MagicPixelTraceHub.shared.startListenerFor(webView, tag: "<OPTIONAL TAG HERE>") { (response) in
	}
