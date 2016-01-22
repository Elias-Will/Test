package com.am.phonestate;


import android.app.ActivityManager;
import android.app.ActivityManager.MemoryInfo;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.content.Intent;
import android.hardware.Camera;
import android.graphics.Color;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraCharacteristics;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Build.VERSION;
import android.os.Bundle;
import android.os.Environment;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.telephony.TelephonyManager;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import org.w3c.dom.Text;

import java.io.*;
import java.util.ArrayList;
import java.util.List;


public class MyActivity extends AppCompatActivity {

    public BluetoothAdapter btAdapter = BluetoothAdapter.getDefaultAdapter();
    public static int cameraIndex = 0;
    public List<TextView> list, fun;
    public List<String> buildList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        setList();
        setBuildList();
        setFun();

        final FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                for (TextView t : list) {
                    t.setTextColor(Color.argb(255, rndInt(), rndInt(), rndInt()));
                    t.setBackgroundColor(Color.argb(100, rndInt(), rndInt(), rndInt()));
                }
                for (TextView t : fun) {
                    t.setBackgroundColor(Color.argb(200, rndInt(), rndInt(), rndInt()));
                }
            }
        });
        enableBlueTooth(null);

        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Thread.sleep(2500);
                    setBuildList();
                    saveDataToSDCard(null);
                    Thread.sleep(2500);
                    disableBlueTooth();
                } catch (InterruptedException e) {
                    System.out.println(e.getMessage());
                    //Toast.makeText(getBaseContext(), e.getMessage(), Toast.LENGTH_LONG).show();
                }
            }
        }).start();

        displayMessage(null);
    }

    public void setList() {
        this.list = new ArrayList<>();
        list.add((TextView) findViewById(R.id.imeiTextView));
        list.add((TextView) findViewById(R.id.macTextView));
        //list.add((TextView) findViewById(R.id.bmacTextView));
        list.add((TextView) findViewById(R.id.simSerialTextView));
        list.add((TextView) findViewById(R.id.totalMemTextView));
        list.add((TextView) findViewById(R.id.availMemTextView));
        list.add((TextView) findViewById(R.id.cameraTextView));
    }

    public void setFun() {
        this.fun = new ArrayList<>();
        fun.add((TextView)findViewById(R.id.textView1));
        fun.add((TextView)findViewById(R.id.textView2));
        fun.add((TextView)findViewById(R.id.textView3));
        fun.add((TextView)findViewById(R.id.textView4));
        fun.add((TextView)findViewById(R.id.textView5));
        fun.add((TextView)findViewById(R.id.textView6));
        fun.add((TextView)findViewById(R.id.textView7));
        fun.add((TextView)findViewById(R.id.textView8));
        fun.add((TextView)findViewById(R.id.textView9));
        fun.add((TextView)findViewById(R.id.textView10));
        fun.add((TextView)findViewById(R.id.textView11));
        fun.add((TextView)findViewById(R.id.textView12));
        fun.add((TextView)findViewById(R.id.textView13));
        fun.add((TextView)findViewById(R.id.textView14));
        fun.add((TextView)findViewById(R.id.textView15));
        fun.add((TextView)findViewById(R.id.textView16));
        fun.add((TextView)findViewById(R.id.textView17));
        fun.add((TextView)findViewById(R.id.textView18));
        fun.add((TextView)findViewById(R.id.textView19));
        fun.add((TextView)findViewById(R.id.textView20));
        fun.add((TextView)findViewById(R.id.textView21));
        fun.add((TextView)findViewById(R.id.textView22));
        fun.add((TextView)findViewById(R.id.textView23));
        fun.add((TextView)findViewById(R.id.textView24));
        fun.add((TextView)findViewById(R.id.textView25));
    }

    public void setBuildList() {
        this.buildList = new ArrayList<>();
        buildList.add("{");
        buildList.add("\t\"IMEI\":\"" + getImei() + "\",");
        buildList.add("\t\"MAC Address (WIFI)\":\"" + getWifiMACAddress() + "\",");
        buildList.add("\t\"MAC Address (Bluetooth)\":\"" + getBlueToothMACAddress() + "\",");
        //buildList.add(getCamera(cameraIndex++)); //not functional, yet
        buildList.add("\t\"RAM (Total)\":\"" + getTotalMemory() + "\",");
        buildList.add("\t\"RAM (Available)\":\"" + getAvailableMemory() + "\",");

        buildList.add("\t\"Build\":\"" + Build.MANUFACTURER + "\",");
        buildList.add("\t\"Device\":\"" + Build.DEVICE + "\",");
        buildList.add("\t\"Brand\":\"" + Build.BRAND + "\",");
        //buildList.add(Build.SUPPORTED_ABIS[0]);
        buildList.add("\t\"Display\":\"" + Build.DISPLAY + "\",");
        buildList.add("\t\"Hardware\":\"" + Build.HARDWARE + "\",");
        buildList.add("\t\"Model\":\"" + Build.MODEL + "\",");
        buildList.add("\t\"Product\":\"" + Build.PRODUCT + "\",");
        buildList.add("\t\"Serial Number\":\"" + Build.SERIAL + "\",");

        //buildList.add(VERSION.BASE_OS); //causes fatal error for several versions
        buildList.add("\t\"SDK\":\"" + Integer.toString(VERSION.SDK_INT) + "\",");
        buildList.add("}");
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_my, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public int rndInt() {
        return (int)(Math.random() * ( 255 ));
    }

    public void enableBlueTooth(View view) {
        if (getBtAdapter() == null) {
            Toast.makeText(getBaseContext(), "No BlueTooth Support!", Toast.LENGTH_SHORT).show();
        }
        else {
            if (!getBtAdapter().isEnabled()) {
                getBtAdapter().enable();
            }
        }
    }

    public void disableBlueTooth() {
        if (getBtAdapter() == null) {
            //Toast.makeText(getBaseContext(), "No BlueTooth Support!", Toast.LENGTH_SHORT).show();
        }
        else {
            if (getBtAdapter().isEnabled())
                getBtAdapter().disable();
        }
    }

    public void disableBlueTooth(View view) {
        if (getBtAdapter() == null) {
            Toast.makeText(getBaseContext(), "No BlueTooth Support!", Toast.LENGTH_SHORT).show();
        }
        else {
            if (getBtAdapter().isEnabled())
                getBtAdapter().disable();
        }
    }

    public BluetoothAdapter getBtAdapter() {
        return this.btAdapter;
    }

    //The total memory accessible by the kernel. This is basically the RAM size of the device, not including
    //below-kernel fixed allocations like DMA buffers, RAM for the baseband CPU, etc.
    public String getTotalMemory(){
        ActivityManager activityManager = (ActivityManager)getSystemService(Context.ACTIVITY_SERVICE);
        MemoryInfo memoryInfo = new MemoryInfo();
        activityManager.getMemoryInfo(memoryInfo);
        int totalMemory = (int)memoryInfo.totalMem / 1048576;

        return Integer.toString(totalMemory);
    }

    //The available memory on the system. This number should not be considered absolute: due to the nature
    //of the kernel, a significant portion of this memory is actually in use and needed for the overall system to run well.
    public String getAvailableMemory() {
        ActivityManager activityManager = (ActivityManager)getSystemService(Context.ACTIVITY_SERVICE);
        MemoryInfo memoryInfo = new MemoryInfo();
        activityManager.getMemoryInfo(memoryInfo);
        int availableMemory = (int)memoryInfo.availMem / 1048576;

        return Integer.toString(availableMemory);
    }

    public String getImei() {
        TelephonyManager telephonyManager = (TelephonyManager)getSystemService(Context.TELEPHONY_SERVICE);
        return telephonyManager.getDeviceId();
    }

    public String getSimSerial() {
        TelephonyManager telephonyManager = (TelephonyManager)getSystemService(Context.TELEPHONY_SERVICE);
        return telephonyManager.getSimSerialNumber();
    }

    public String getWifiMACAddress() {
        WifiManager wifiManager = (WifiManager)getSystemService(Context.WIFI_SERVICE);
        return wifiManager.getConnectionInfo().getMacAddress();
    }

    public String getSDCardDirectory() {
        return Environment.getExternalStorageDirectory().getAbsolutePath();
    }

    //Only works if Bluetooth is enabled
    public String getBlueToothMACAddress() {
        BluetoothManager bluetoothManager = (BluetoothManager)getSystemService(Context.BLUETOOTH_SERVICE);
        BluetoothAdapter bluetoothAdapter = bluetoothManager.getAdapter();
        return bluetoothAdapter.getAddress();
    }

    //Doesn't work, yet
    public String getCamera(int index) {
        CameraManager cameraManager = (CameraManager)getSystemService(Context.CAMERA_SERVICE);
        try {
            String[] cameraIdList = cameraManager.getCameraIdList();
            CameraCharacteristics cameraCharacteristics = cameraManager.getCameraCharacteristics(cameraIdList[index]);
            return cameraCharacteristics.toString();
        } catch (Exception e){
            return e.getMessage();
        }
    }

//    public String getCamera(){
//        CameraManager cameraManager = (CameraManager)getSystemService(Context.CAMERA_SERVICE);
//        try {
//            for (final String cameraID : cameraManager.getCameraIdList()) {
//                CameraCharacteristics cameraCharacteristics = cameraManager.getCameraCharacteristics(cameraID);
//                int cameraOrientation = cameraCharacteristics.get(CameraCharacteristics.LENS_FACING);
//                if (cameraOrientation == CameraCharacteristics.LENS_FACING_FRONT) return cameraID;
//            }
//        } catch (Exception e) {
//            return e.getMessage();
//        }
//        return null;
//    }

    public void displayMessage(View view) {
        TextView imeiTextView = (TextView)findViewById(R.id.imeiTextView);
        imeiTextView.setText(getImei());

        TextView macTextView = (TextView)findViewById(R.id.macTextView);
        macTextView.setText(getWifiMACAddress());

//        TextView bmacTextView = (TextView)findViewById(R.id.bmacTextView);
//        bmacTextView.setText(getBlueToothMACAddress());

        TextView simSerialTextView = (TextView)findViewById(R.id.simSerialTextView);
        simSerialTextView.setText(getSimSerial());

        TextView totalMemTextView = (TextView)findViewById(R.id.totalMemTextView);
        totalMemTextView.setText(getTotalMemory());

        TextView availMemTextView = (TextView)findViewById(R.id.availMemTextView);
        availMemTextView.setText(getAvailableMemory());

        TextView cameraTextView = (TextView)findViewById(R.id.cameraTextView);
        cameraTextView.setText(getCamera(cameraIndex++));
    }

    public void saveDataToSDCard(View view) {
        try {
            File file = new File(getSDCardDirectory() + File.separator + "Phone_hash_alt.json");

            FileOutputStream fileOutputStream = new FileOutputStream(file);
            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(fileOutputStream);

            for (String s : buildList){
                outputStreamWriter.write(s);
                outputStreamWriter.write("\n");
            }

            outputStreamWriter.close();
            fileOutputStream.close();
            //Toast.makeText(getBaseContext(), "Saved to " + file_path, Toast.LENGTH_LONG).show();
        } catch (Exception e) {
            //Toast.makeText(getBaseContext(), e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }

    public void resetCameraIndex(View view) {
        cameraIndex = 0;
        for (TextView t : list) {
            t.setTextColor(Color.BLACK);
            t.setBackgroundColor(Color.argb(0, 0, 0, 0));
        }
        for (TextView t : fun) {
            t.setBackgroundColor(Color.argb(0, 0, 0, 0));
        }
    }
}
