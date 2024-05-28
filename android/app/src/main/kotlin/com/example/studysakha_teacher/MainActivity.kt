package com.example.studysakha_teacher

import android.app.Activity
import io.flutter.embedding.android.FlutterActivity
import live.hms.hmssdk_flutter.HmssdkFlutterPlugin
import io.flutter.embedding.android.FlutterFragmentActivity
import android.content.Intent
import live.hms.hmssdk_flutter.Constants
class MainActivity: FlutterActivity() {
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == Constants.SCREEN_SHARE_INTENT_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            data?.action = Constants.HMSSDK_RECEIVER
            this.sendBroadcast(data?.putExtra(Constants.METHOD_CALL, Constants.SCREEN_SHARE_REQUEST))
        }
    }
}



