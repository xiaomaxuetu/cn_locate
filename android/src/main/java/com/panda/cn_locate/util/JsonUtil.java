package com.panda.cn_locate.util;

import com.panda.cn_locate.BuildConfig;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

public class JsonUtil {
    public static String toJson(Map<String, Object> map) {
        JSONObject jsonObject = new JSONObject();
        try {
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                jsonObject.put(entry.getKey(), entry.getValue());
            }
        } catch (JSONException e) {
            if (BuildConfig.DEBUG)
                e.printStackTrace();
        }
        return jsonObject.toString();
    }
}
