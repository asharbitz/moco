on run argv
  local browsers, urls
  set {browsers, urls} to parse(argv)
  if browsers contains "Canary"  then reloadCanary(urls)
  if browsers contains "Chrome"  then reloadChrome(urls)
  if browsers contains "Firefox" then reloadFirefox(urls)
  if browsers contains "Opera"   then reloadOpera(urls)
  if browsers contains "Safari"  then reloadSafari(urls)
  if browsers contains "WebKit"  then reloadWebKit(urls)
  return
end

on parse(argv)
  set urls to {}
  set browsers to {}
  set allBrowsers to {"Canary", "Chrome", "Firefox", "Opera", "Safari", "WebKit"}

  repeat with arg in argv
    set arg to arg as string
    if allBrowsers contains arg then
      set browsers to browsers & arg
    else
      set urls to urls & arg
    end
  end

  if browsers = {} then set browsers to allBrowsers

  return {browsers, urls}
end

on shouldReload(_url, urls)
  if _url = "" then return false
  if urls = {} then return true
  repeat with u in urls
    if _url starts with u then return true
  end
  return false
end

on reloadSafari(urls)
  reloadSafariWebKit("Safari", urls)
end

on reloadWebKit(urls)
  reloadSafariWebKit("WebKit", urls)
end

on reloadSafariWebKit(browser, urls)
  using terms from application "Safari"
    tell application browser
      if it is not running then return
      if (windows where visible is true) = {} then return
      if not (front document exists) then return

      tell front document
        if my shouldReload(URL as string, urls) then
          do JavaScript "location.reload()"
        end
      end
    end
  end
end

on reloadChrome(urls)
  reloadGoogleChrome("Google Chrome", urls)
end

on reloadCanary(urls)
  reloadGoogleChrome("Google Chrome Canary", urls)
end

on reloadGoogleChrome(browser, urls)
  using terms from application "Google Chrome"
    tell application browser
      if it is not running then return
      if (windows where visible is true) = {} then return

      tell active tab of front window
        if my shouldReload(URL, urls) then reload
      end
    end
  end
end

on reloadOpera(urls)
  tell application "Opera"
    if it is not running then return

    if my shouldReload(URL of front document as string, urls) then
      set URL of front document to "javascript:location.reload()"
    end
  end
end

on reloadFirefox(urls)
  tell application "Firefox"
    if it is not running then return
    if (windows where visible is true) = {} then return

    set frontApp to my findFrontApp()
    activate
    if my shouldReload(my copyUrl(), urls) then my doReload()
    my resetFrontApp(frontApp)
  end
end

on copyUrl()
  set the clipboard to ""
  tell application "System Events"
    delay 0.01
    keystroke "l" using {command down}
    delay 0.01
    keystroke "c" using {command down}
    delay 0.1
  end
  return the clipboard as string
end

on doReload()
  tell application "System Events"
    delay 0.01
    keystroke "r" using {command down}
  end
end

on findFrontApp()
  tell application "System Events"
    return first process where frontmost is true
  end
end

on resetFrontApp(frontApp)
  tell frontApp to set frontmost to true
end
