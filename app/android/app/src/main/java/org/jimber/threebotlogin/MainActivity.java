package org.jimber.threebotlogin.local;

import android.app.NotificationManager;
import android.content.Context;

import android.os.Bundle;
import io.flutter.app.FlutterFragmentActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterFragmentActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    //getWindow().addFlags(LayoutParams.FLAG_SECURE);   // preventing screenshot
  }

  @Override
    protected void onResume() {
        super.onResume();

        // Removing All Notifications
        cancelAllNotifications();
    }

    private void cancelAllNotifications() {
        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancelAll();
    }
}
