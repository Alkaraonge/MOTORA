package com.kemet.independent;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.os.Bundle;
import android.webkit.JavascriptInterface;
import android.webkit.RenderProcessGoneDetail;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebSettings;
import android.view.Gravity;
import android.widget.TextView;

/** Independent, offline, read-only demonstration. No vehicle control, ADB or networks. */
public final class MainActivity extends Activity {
    private WebView webView;

    public final class LocalExport {
        @JavascriptInterface
        public void shareText(String filename, String text) {
            if (text == null || text.length() > 200000 || filename == null) return;
            runOnUiThread(() -> {
                Intent intent = new Intent(Intent.ACTION_SEND);
                intent.setType("text/plain");
                intent.putExtra(Intent.EXTRA_SUBJECT, filename);
                intent.putExtra(Intent.EXTRA_TEXT, text);
                try { startActivity(Intent.createChooser(intent, "Export local demo data")); }
                catch (Exception e) { showError("Export is not supported on this device."); }
            });
        }
    }

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        getWindow().setStatusBarColor(Color.rgb(4, 9, 18));
        getWindow().setNavigationBarColor(Color.rgb(3, 6, 12));
        try {
            WebView ui = new WebView(this);
            webView = ui;
            ui.setBackgroundColor(Color.rgb(6, 9, 22));
            WebSettings s = ui.getSettings();
            s.setJavaScriptEnabled(true);
            s.setDomStorageEnabled(true);
            s.setDefaultTextEncodingName("UTF-8");
            s.setAllowContentAccess(false);
            s.setAllowFileAccess(true);
            s.setAllowFileAccessFromFileURLs(false);
            s.setAllowUniversalAccessFromFileURLs(false);
            s.setJavaScriptCanOpenWindowsAutomatically(false);
            s.setSupportMultipleWindows(false);
            ui.addJavascriptInterface(new LocalExport(), "DBCNative");
            ui.setWebChromeClient(new WebChromeClient());
            ui.setWebViewClient(new WebViewClient() {
                @Override public boolean shouldOverrideUrlLoading(WebView v, WebResourceRequest req) {
                    return !"file:///android_asset/index.html".equals(req.getUrl().toString());
                }
                @Override public boolean onRenderProcessGone(WebView v, RenderProcessGoneDetail detail) {
                    webView = null;
                    showError("Android System WebView stopped. Please update Chrome / Android System WebView and restart this app.");
                    v.destroy();
                    return true;
                }
            });
            setContentView(ui);
            ui.loadUrl("file:///android_asset/index.html");
        } catch (Throwable t) {
            showError("Unable to start the local interface: " + t.getClass().getSimpleName());
        }
    }

    private void showError(String message) {
        TextView label = new TextView(this);
        label.setText("DBC Independent 1.1.0\n\n" + message + "\n\nNo car settings were changed.");
        label.setGravity(Gravity.CENTER);
        label.setTextColor(Color.WHITE);
        label.setTextSize(18);
        label.setPadding(36, 36, 36, 36);
        label.setBackgroundColor(Color.rgb(6, 9, 22));
        setContentView(label);
    }

    @Override public void onBackPressed() {
        if (webView != null) { webView.evaluateJavascript("window.dispatchEvent(new KeyboardEvent('keydown',{key:'Escape'}))", null); }
        else super.onBackPressed();
    }
    @Override protected void onDestroy() {
        if (webView != null) { webView.removeJavascriptInterface("DBCNative"); webView.destroy(); webView = null; }
        super.onDestroy();
    }
}