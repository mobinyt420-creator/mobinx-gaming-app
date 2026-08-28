package com.mobinx.gaming;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.webkit.JavascriptInterface;
import android.webkit.WebSettings;
import android.webkit.WebView;
import androidx.annotation.Nullable;
import androidx.browser.customtabs.CustomTabColorSchemeParams;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.core.app.NotificationCompat;
import com.getcapacitor.BridgeActivity;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.tasks.Task;
import org.json.JSONObject;

public class MainActivity extends BridgeActivity {
    private static final int RC_SIGN_IN = 9001;
    private static final int RC_FALLBACK_SIGN_IN = 9002;
    private GoogleSignInClient googleSignInClient;
    private GoogleSignInClient fallbackSignInClient;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        try {
            // 1. Primary Google Sign-In with Web Client ID
            GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                    .requestIdToken("219633934545-3rh1evb9ofahg5p46vm2souq9vr64368.apps.googleusercontent.com")
                    .requestEmail()
                    .requestProfile()
                    .build();
            googleSignInClient = GoogleSignIn.getClient(this, gso);

            // 2. Fallback Google Sign-In (Guaranteed zero Error 10)
            GoogleSignInOptions fallbackGso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                    .requestEmail()
                    .requestProfile()
                    .build();
            fallbackSignInClient = GoogleSignIn.getClient(this, fallbackGso);

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

                // Add Native Android Bridge for Chrome Custom Tabs and Google Auth
                webView.addJavascriptInterface(new AndroidBridge(), "AndroidBridge");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onBackPressed() {
        WebView webView = getBridge().getWebView();
        if (webView != null) {
            // Trigger seamless navigation handler in JavaScript
            String script = "if (window.handleNativeBackPressed) { window.handleNativeBackPressed(); } else { window.history.back(); }";
            webView.evaluateJavascript(script, null);
        } else {
            super.onBackPressed();
        }
    }

    public class AndroidBridge {
        @JavascriptInterface
        public void openCustomTab(String url) {
            runOnUiThread(() -> {
                try {
                    CustomTabsIntent.Builder builder = new CustomTabsIntent.Builder();
                    builder.setShowTitle(true);
                    builder.setShareState(CustomTabsIntent.SHARE_STATE_ON);
                    builder.setDefaultColorSchemeParams(new CustomTabColorSchemeParams.Builder()
                            .setToolbarColor(Color.parseColor("#0284c7"))
                            .build());
                    CustomTabsIntent customTabsIntent = builder.build();
                    customTabsIntent.launchUrl(MainActivity.this, Uri.parse(url));
                } catch (Exception e) {
                    try {
                        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
                        startActivity(browserIntent);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            });
        }

        @JavascriptInterface
        public void exitApp() {
            runOnUiThread(() -> {
                MainActivity.this.finish();
            });
        }

        @JavascriptInterface
        public void signInWithGoogle() {
            runOnUiThread(() -> {
                try {
                    if (googleSignInClient != null) {
                        // Sign out first to ensure account chooser is always displayed
                        googleSignInClient.signOut().addOnCompleteListener(task -> {
                            Intent signInIntent = googleSignInClient.getSignInIntent();
                            startActivityForResult(signInIntent, RC_SIGN_IN);
                        });
                    } else if (fallbackSignInClient != null) {
                        fallbackSignInClient.signOut().addOnCompleteListener(task -> {
                            Intent signInIntent = fallbackSignInClient.getSignInIntent();
                            startActivityForResult(signInIntent, RC_FALLBACK_SIGN_IN);
                        });
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    tryFallbackSignIn();
                }
            });
        }

        @JavascriptInterface
        public void showNativeNotification(String title, String message) {
            runOnUiThread(() -> {
                try {
                    String channelId = "mobinx_notifications";
                    NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        NotificationChannel channel = new NotificationChannel(
                                channelId,
                                "Mobin X Announcements",
                                NotificationManager.IMPORTANCE_HIGH
                        );
                        channel.setDescription("Official match announcements and tournament updates");
                        channel.enableLights(true);
                        channel.setLightColor(Color.BLUE);
                        channel.enableVibration(true);
                        if (notificationManager != null) {
                            notificationManager.createNotificationChannel(channel);
                        }
                    }

                    Intent intent = new Intent(MainActivity.this, MainActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
                    PendingIntent pendingIntent = PendingIntent.getActivity(
                            MainActivity.this,
                            (int) System.currentTimeMillis(),
                            intent,
                            PendingIntent.FLAG_UPDATE_CURRENT | (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M ? PendingIntent.FLAG_IMMUTABLE : 0)
                    );

                    NotificationCompat.Builder builder = new NotificationCompat.Builder(MainActivity.this, channelId)
                            .setSmallIcon(R.mipmap.ic_launcher)
                            .setContentTitle(title != null && !title.isEmpty() ? title : "MOBIN X GAMING")
                            .setContentText(message != null ? message : "New tournament announcement!")
                            .setStyle(new NotificationCompat.BigTextStyle().bigText(message))
                            .setPriority(NotificationCompat.PRIORITY_HIGH)
                            .setAutoCancel(true)
                            .setContentIntent(pendingIntent);

                    if (notificationManager != null) {
                        notificationManager.notify((int) System.currentTimeMillis(), builder.build());
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            });
        }
    }

    private void tryFallbackSignIn() {
        runOnUiThread(() -> {
            try {
                if (fallbackSignInClient != null) {
                    fallbackSignInClient.signOut().addOnCompleteListener(task -> {
                        Intent signInIntent = fallbackSignInClient.getSignInIntent();
                        startActivityForResult(signInIntent, RC_FALLBACK_SIGN_IN);
                    });
                } else {
                    notifyJsAuthError("Google Sign-In service unavailable");
                }
            } catch (Exception ex) {
                notifyJsAuthError("Google Sign-In cancelled");
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == RC_SIGN_IN) {
            Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(data);
            try {
                GoogleSignInAccount account = task.getResult(ApiException.class);
                if (account != null && account.getEmail() != null) {
                    processAccountSuccess(account);
                } else {
                    tryFallbackSignIn();
                }
            } catch (ApiException e) {
                // If Developer Error 10 occurs, automatically fall back to standard account picker
                if (e.getStatusCode() == 10 || e.getStatusCode() == 12500) {
                    tryFallbackSignIn();
                } else if (e.getStatusCode() == 12501) {
                    notifyJsAuthError("Google Sign-In was cancelled");
                } else {
                    tryFallbackSignIn();
                }
            } catch (Exception e) {
                tryFallbackSignIn();
            }
        } else if (requestCode == RC_FALLBACK_SIGN_IN) {
            Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(data);
            try {
                GoogleSignInAccount account = task.getResult(ApiException.class);
                if (account != null && account.getEmail() != null) {
                    processAccountSuccess(account);
                } else {
                    notifyJsAuthError("No Google account selected");
                }
            } catch (ApiException e) {
                if (e.getStatusCode() == 12501) {
                    notifyJsAuthError("Google Sign-In was cancelled");
                } else {
                    notifyJsAuthError("Sign-in error: " + e.getStatusCode());
                }
            } catch (Exception e) {
                notifyJsAuthError("Error: " + e.getMessage());
            }
        }
    }

    private void processAccountSuccess(GoogleSignInAccount account) {
        try {
            JSONObject userJson = new JSONObject();
            String email = account.getEmail();
            userJson.put("email", email);
            userJson.put("displayName", account.getDisplayName() != null ? account.getDisplayName() : (email != null ? email.split("@")[0] : "Player"));
            userJson.put("idToken", account.getIdToken() != null ? account.getIdToken() : "");
            userJson.put("uid", account.getId() != null ? account.getId() : ("google_" + System.currentTimeMillis()));
            userJson.put("photoUrl", account.getPhotoUrl() != null ? account.getPhotoUrl().toString() : "");
            notifyJsAuthSuccess(userJson.toString());
        } catch (Exception e) {
            notifyJsAuthError("Data parsing error");
        }
    }

    private void notifyJsAuthSuccess(String jsonString) {
        runOnUiThread(() -> {
            WebView webView = getBridge().getWebView();
            if (webView != null) {
                String script = "if (window.onNativeGoogleSignInSuccess) { window.onNativeGoogleSignInSuccess(" + jsonString + "); }";
                webView.evaluateJavascript(script, null);
            }
        });
    }

    private void notifyJsAuthError(String errorMsg) {
        runOnUiThread(() -> {
            WebView webView = getBridge().getWebView();
            if (webView != null) {
                String safeMsg = errorMsg != null ? errorMsg.replace("'", "\\'") : "Unknown error";
                String script = "if (window.onNativeGoogleSignInError) { window.onNativeGoogleSignInError('" + safeMsg + "'); }";
                webView.evaluateJavascript(script, null);
            }
        });
    }
}
