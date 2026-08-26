package com.mobinx.gaming;

import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        try {
            WebView webView = getBridge().getWebView();
            if (webView != null) {
                WebSettings settings = webView.getSettings();
                String ua = settings.getUserAgentString();
                // Strip '; wv' to prevent Google's 403 disallowed_useragent block in WebViews
                if (ua != null && ua.contains("; wv")) {
                    ua = ua.replace("; wv", "");
                    settings.setUserAgentString(ua);
                }
                settings.setDomStorageEnabled(true);
                settings.setDatabaseEnabled(true);
                settings.setJavaScriptCanOpenWindowsAutomatically(true);
                settings.setSupportMultipleWindows(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
