package com.isonas.service;

import com.britesnow.snow.web.param.annotation.WebParam;
import com.britesnow.snow.web.rest.annotation.WebPost;
import com.google.inject.Inject;
import com.google.inject.Singleton;
import com.isonas.AppException;
import com.isonas.dao.TenantDao;
import com.isonas.dao.UserDao;
import com.isonas.entity.*;
import com.isonas.web.WebResponse;
import com.isonas.web.WebResponseBuilder;
import com.isonas.web.WebSocketHistorySessionHandler;
import com.isonas.web.WebSocketSessionHandler;
import com.isonas.web.annotation.JsonArrayParam;
import com.isonas.web.httpclient.HttpClientService;
import net.sf.json.JSON;
import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.j8ql.Record;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by kiril on 1/10/2017.
 */

@Singleton
public class WebSocketService {
    private static final Logger logger = LoggerFactory.getLogger(WebSocketService.class);

    @Inject
    private TimezoneService timezoneService;

    @Inject
    private UserDao userDao;

    @Inject
    private TenantDao tenantDao;

    @Inject
    private HttpClientService httpClientService;

    @Inject
    private WebResponseBuilder webResponseBuilder;

    @Inject
    private AWSService awsService;

    public enum WebSocketEvents{
        OnConnection,
        OnActivity,
        OnAccesspointStatus,
        OnClosedStatus,
        OnConnectedStatus,
        OnAlert,
        OnSessionExpired
    }

    public enum WebSocketActions{
        SaveUserId
    }

    @WebPost("/lookupWebSocketSessions")
    public WebResponse lookupWebSocketSessions(@JsonArrayParam("userIds") List<Integer> userIds, @WebParam("message") String message){
        try {
            for (Integer userIdInt : userIds) {
                Long userId = Long.parseLong(userIdInt.toString());
                if (WebSocketSessionHandler.sendToUser(userId, message) == 0) {
                } else {
                    //logger.debug("Couldn't Send to User");
                }
            }
        } catch (ClassCastException e) {
            //logger.error(e.getMessage());
            return webResponseBuilder.fail(e);
        } catch (Exception e) {
            //logger.error(e.getMessage());
            return webResponseBuilder.fail(e);
        }

        return webResponseBuilder.success(message);
    }

    @WebPost("/lookupWebSocketHistorySessions")
    public WebResponse lookupWebSocketHistorySessions(@JsonArrayParam("userIds") List<Integer> userIds, @WebParam("message") String message){
        try {
            for (Integer userIdInt : userIds) {
                Long userId = Long.parseLong(userIdInt.toString());
                if (WebSocketHistorySessionHandler.sendToUser(userId, message) == 0) {
                } else {
                    //logger.debug("Couldn't Send to User");
                }
            }
        } catch (ClassCastException e) {
            //logger.error(e.getMessage());
            return webResponseBuilder.fail(e);
        } catch (Exception e) {
            //logger.error(e.getMessage());
            return webResponseBuilder.fail(e);
        }

        return webResponseBuilder.success(message);
    }

    // Kick Out a User if Their Session is no Longer Valid
    public void sendLogout(User user) {
        try {
            Long userId = user.getId();
            List<Long> userIds = new ArrayList<>();
            userIds.add(userId);
            JSONObject result = new JSONObject();
            result.put("userId", userId);
            JSON message = WebSocketSessionHandler.createMessage(WebSocketEvents.OnSessionExpired, result);
            lookOnOtherServers(userIds, message);
        } catch (Exception e) {
            logger.error("Couldn't Logout User");
        }
    }

    // Send History after Processing Data
    // Returns "0" if success, "-1" otherwise
    public int sendHistory(Activity activity) {
        try {
            TimezoneService.TimeZoneConfig timeZoneConfig = timezoneService.getTimezoneConfigsByAp(null, activity.getAccesspointId());
            JSONObject result = (JSONObject) JSONSerializer.toJSON(activity);
            String timezoneId = timezoneService.convertTimezoneConfigToTimezoneId(timeZoneConfig);
            result.put("timezoneString", timezoneId);
            result.put(
                    "profileId",
                    userDao.getUserProfileId(activity.getUserId())
            );
            JSON message = WebSocketHistorySessionHandler.createMessage(WebSocketEvents.OnActivity, result);
            List<Long> userIds = getUsersSubscribedToActivity(activity.getTenantId());
            lookOnOtherServersHistory(userIds, message);
            return 0;
        } catch (Exception e) {
            //logger.error("Couldn't Send History");
            return -1;
        }
    }

    // SendAlertUpdate after Processing Data
    public void sendAlertUpdate(Alert alert) {
        try {
            List<Long> userIds = getUsersUnderTenantByAccesspointId(alert.getAccesspointId());
            JSONObject result = JSONObject.fromObject(alert);
            JSON message = WebSocketSessionHandler.createMessage(WebSocketEvents.OnAlert, result);
            lookOnOtherServers(userIds, message);
        } catch (Exception e) {
            //logger.error("Couldn't Send Aleart");
        }
    }

    // Send Connected Status after Processing Data
    public void sendConnectedStatus(Long accesspointId, Boolean isConnected) {
        try {
            List<Long> userIds = getUsersUnderTenantByAccesspointId(accesspointId);
            JSONObject result = new JSONObject();
            result.put("accesspointId", accesspointId);
            result.put("isConnected", isConnected);
            JSON message = WebSocketSessionHandler.createMessage(WebSocketEvents.OnConnectedStatus, result);
            lookOnOtherServers(userIds, message);
        } catch (Exception e) {
            //logger.error("Couldn't Send Connected Status");
        }
    }


    public int sendHistory(CredentialActivity activity) {
        try {
            TimezoneService.TimeZoneConfig timeZoneConfig = timezoneService.getTimezoneConfigsByAp(null, activity.getAccesspointId());
            JSONObject result = (JSONObject) JSONSerializer.toJSON(activity);
            String timezoneId = timezoneService.convertTimezoneConfigToTimezoneId(timeZoneConfig);
            result.put("timezoneString", timezoneId);
            result.put(
                    "profileId",
                    userDao.getUserProfileId(activity.getUserId())
            );
            JSON message = WebSocketHistorySessionHandler.createMessage(WebSocketEvents.OnActivity, result);
            List<Long> userIds = getUsersUnderTenantByAccesspointId(activity.getAccesspointId());
            lookOnOtherServersHistory(userIds, message);
            return 0;
        } catch (Exception e) {
            return -1;
        }
    }

    public Boolean isUserSessionAvailable(Long id) {
        return WebSocketSessionHandler.isUserSessionAvailable(id);
    }

    public void lookOnOtherServers(List<Long> userId, JSON data){
        List<String> urls = awsService.getServerURLs();
        for (String url : urls) {
            postJSONDataToUrl(url, userId, data);
        }
    }

    public void lookOnOtherServersHistory(List<Long> userId, JSON data){
        List<String> urls = awsService.getServerURLsHistory();
        for (String url : urls) {
            postJSONDataToUrl(url, userId, data);
        }
    }

    public int sendClosedStatus(AccesspointStatus accesspointStatus){
        try {
            JSONObject accesspointStatusJSON = new JSONObject();
            accesspointStatusJSON.put("accesspointId", accesspointStatus.getAccesspointId());
            accesspointStatusJSON.put("openStatus", accesspointStatus.getOpenStatus());
            List<Long> userIds = getUsersUnderTenantByAccesspointId(accesspointStatus.getAccesspointId());
            lookOnOtherServers(userIds, accesspointStatusJSON);
            return 0;
        } catch (Exception e) {
            return -1;
        }
    }

    public List<Long> getUsersSubscribedToActivity(Long tenantId) {
        List<Long> userList = WebSocketSessionHandler.getUsersForTenant(tenantId);
        return userList;
    }

    private List<Long> getUsersUnderTenantByAccesspointId(Long accesspointId) {
        List<Long> userList = new ArrayList<>();
        User user = userDao.getBackgroundUserByAccesspoint(accesspointId);
        List<Record> recordList = tenantDao.getTenantsByUser(user, user.getId());
        for (Record record : recordList) {
            Long tenantId = (Long) record.get("id");
            userList.addAll(getUsersSubscribedToActivity(tenantId));
        }
        return userList;
    }

    public void postJSONDataToUrl(String url, List<Long> userId, JSON data) throws AppException {
        List<NameValuePair> parameters;
        HttpResponse httpResponse;
        HttpClientService.SimpleHttpClient simpleHttpClient = httpClientService.createHttpClient(url);
        try {
            parameters = httpClientService.convertJSONObjectToNameValuePair(userId, data);
        } catch (Exception e) {
            throw new AppException("Couldn't Convert Input Parameters");
        }
        try {
            httpResponse = simpleHttpClient.sendHTTPPost(parameters);
        } catch (Exception e) {
            throw new AppException("Couldn't Get Data from the Server");
        }
        if (httpResponse == null) {
            throw new AppException("Couldn't Send to Another Server");
        } else {
            //logger.error(httpResponse.getStatusLine().toString());
        }
    }
}
