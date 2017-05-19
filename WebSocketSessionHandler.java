package com.isonas.web;

import javax.json.*;
import java.lang.reflect.Array;
import java.util.*;

import com.isonas.service.DeviceConnectedTimeManager;
import net.sf.json.JSON;

import java.io.IOException;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import javax.websocket.Session;
import javax.json.spi.JsonProvider;
import com.isonas.service.WebSocketService.WebSocketEvents;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Created by kiril on 9/30/2016.
 */

public class WebSocketSessionHandler {

    // Apparently required to instantiate the dialogue,
    // ideally it would be better to just create session map where sessions are mapped to userId,
    // however, userId will be send only after the session is created.
    // TODO: Investigate Instantiation of WebSocket Session Further

    private static final Logger logger = LoggerFactory.getLogger(WebSocketSessionHandler.class);

    private static final Map<Session, List<Long>> sessions = new HashMap<>();

    // WeakHashMap is Used for Automatic Memory Management (So That Removal of Keys That are no Longer Used Can be Automatically Performed)
    // NOTE: However, it Requires Certain Precautions to Make Sure Their Keys Don't Expire Unexpectedly, Look for the Commented Code Below
    private static final Map<Long, Set<Session>> sessionMap = new WeakHashMap<>();

    private static final Map<Long, Set<Long>> tenantUserMap = new WeakHashMap<>();

    public WebSocketSessionHandler() {}

    public static List<Long> getUsersForTenant(Long tenantId) {
        List<Long> userIds = new ArrayList<>();
        Set<Long> userIdsSet = tenantUserMap.get(tenantId);
        if (userIdsSet != null) {
            for (Long userId : userIdsSet){
                userIds.add(userId);
            }
        }
        return userIds;
    }

    public static Boolean isUserSessionAvailable(Long id){
        Set<Session> userSessions =  sessionMap.get(id);
        if (userSessions == null || userSessions.size() == 0) {
            return false;
        } else {
            return true;
        }
    }

    // addSession() should add "session" to "sessions" set
    // returns: "0" if success and "-1" otherwise
    public static int addSession(Session session) {
        int output;
        try {
            final long ONE_DAY = 86400000;
            session.setMaxIdleTimeout(ONE_DAY);
            sessions.put(session, new ArrayList<>());
            return sendToSession(session, createMessage(WebSocketEvents.OnConnection, "Successfully Connected"));
        } catch (Exception e) {
            logger.error("Couldn't Add Session");
            return -1;
        }
    }

    // removeSession() should remove "session" from "sessions" set
    // Scenarios:
    // sessions is null?
    // returns: "0" if success and "-1" otherwise
    public static int removeSession( Session session) {
        try {
            closeSessionProperly(session);
            if (sessions.remove(session) != null) {
                return 0;
            } else {
                return -1;
            }
        } catch (Exception e) {
            logger.error("Couldn't Remove Session");
            return -1;
        }
    }

    private static void closeSessionProperly(Session session) {
        try {
            session.close();
        } catch (IOException ex) {

        }
    }

    public static Long getKeyFromMap(Map map, Long key){ // Needed for Weak Maps
        Set<Long> keySet = map.keySet();
        for (Long keyReference : keySet) {
            if (keyReference == key) {
                return keyReference;
            }
        }
        return key; // If Not Found Return the Value Passed in
    }

    // saveUserId() should create an { userId -> session } entry in sessionMap
    public static Long  saveUserId(Long userId,  Session session){
        // Test Scenarios:
        // Can userId be null or wrong?
        // Can session be null or wrong?
        try {
            userId = getKeyFromMap(sessionMap, userId); // Required for Weak Maps to Work Correctly
            Set<Session> sessionsForUser = sessionMap.get(userId);
            if (sessionsForUser == null) {
                sessionsForUser = new HashSet<>();
            }
            sessionsForUser.add(session);
            sessionMap.put(userId, sessionsForUser);
            return userId;
        } catch (Exception e) {
            logger.error("Couldn't Save User Id");
            return null;
        }
    }

    // saveUserId() should create an { userId -> session } entry in sessionMap
    public static Long  saveTenantUser(Long tenantId,  Long userId){
        // Test Scenarios:
        // Can userId be null or wrong?
        // Can session be null or wrong?
        try {
            tenantId = getKeyFromMap(tenantUserMap, tenantId); // Required for Weak Maps to Work Correctly
            Set<Long> users = tenantUserMap.get(tenantId);
            if (users == null) {
                users = new HashSet<>();
            }
            users.add(userId);
            tenantUserMap.put(tenantId, users);
            return tenantId;
        } catch (Exception e) {
            logger.error("Couldn't Save Tenant User");
            return null;
        }
    }

    public static void updateUserSessionKeys(Session session, Long tenantId, Long userId) {
        try {
            List<Long> userSessionKeys = sessions.get(session);
            userSessionKeys.add(0, tenantId);
            userSessionKeys.add(1, userId);
        } catch (Exception e) {
            logger.error("Couldn't Update User Session Keys");
        }
    }

    // removeUserId() should remove an { userId -> session } entry in sessionMap
    // returns: "0" if success and "-1" otherwise
    public static int removeUserId( Long userId) {
        try {
            sessionMap.remove(userId);
            return 0;
        } catch (Exception e) {
            return -1;
        }
    }

    // sendAccesspointStatus() should compose JSON message and pass it to sendToUser()
    // returns: "0" if success and "-1" otherwise
    public static int sendClosedStatus(Long userId, JSONObject accesspointStatus) {
        try {
            JSONObject accesspointStatusEventMessage = (JSONObject) createMessage(WebSocketEvents.OnClosedStatus, accesspointStatus);
            sendToUser(userId, accesspointStatusEventMessage);
            return 0;
        } catch (Exception e) {
            return -1;
        }
    }

    // sendToUser() sends message to session that is mapped to userId
    // returns: "0" if success and "-1" otherwise
    public static int sendToUser( Long userId, JSON message) {

        if (sessionMap.containsKey(userId)) {
            Set<Session> sessionsForUser = sessionMap.get(userId);
            for (Session session : sessionsForUser) {
                if (!session.isOpen()) {
                    sessions.remove(session);
                    continue;
                }
                sendToSession(session, message);
            }
            return 0;
        } else {
            return -1;
        }
    }

    // sendToUser() sends message to session that is mapped to userId
    // returns: "0" if success and "-1" otherwise
    public static int sendToUser( Long userId, String message) {
        if (sessionMap.containsKey(userId)) {
            Set<Session> sessionsForUser = sessionMap.get(userId);
            for (Session session : sessionsForUser) {
                if (!session.isOpen()) {
                    sessions.remove(session);
                    continue;
                }
                sendToSession(session, message);
            }
            return 0;
        } else {
            return -1;
        }
    }

    // sendToSession() sends string message to session
    // returns: "0" if success and "-1" otherwise
    private static int sendToSession( Session session,  JSON message){
        try {
            try {
                Long tenantId = sessions.get(session).get(0);
                ((JSONObject) message).put("tenantId", tenantId);
            } catch (Exception e) {
                logger.error("No tenantId Found");
            }
            session.getBasicRemote().sendText(message.toString());
            return 0;
        } catch (IOException e) {
            try {
                session.close();
            } catch (IOException ex) {

            }

            closeSessionProperly(session);
            sessions.remove(session);

            return -1;
        }
    }

    // sendToSession() sends string message to session
    // returns: "0" if success and "-1" otherwise
    private static int sendToSession( Session session,  String message){
        try {
            JSONObject newMessage = JSONObject.fromObject(message);
            try {
                Long tenantId = sessions.get(session).get(0);
                newMessage.put("tenantId", tenantId);
            } catch (Exception e) {
                logger.error("No tenantId Found");
            }
            session.getBasicRemote().sendText(newMessage.toString());
            return 0;
        } catch (IOException e) {
            closeSessionProperly(session);
            sessions.remove(session);
            return -1;
        }
    }

    // createMessage() generates JSON wrapper that includes event name and payload
    private static JsonObject createMessage( String event){
        JsonProvider provider = JsonProvider.provider();
        JsonObject result = provider.createObjectBuilder()
                    .add("event", event)
                    .build();
        return result;
    }

    // createMessage() generates JSON wrapper that includes event name and payload
    public static JsonObject createMessage( String event,  String payload){
        JsonProvider provider = JsonProvider.provider();
        JsonObject result = provider.createObjectBuilder()
                .add("event", event)
                .add("payload", payload)
                .build();
        return result;
    }

    // createMessage() generates JSON wrapper that includes event name and payload
    public static JSON createMessage( WebSocketEvents event,  String payload){
        JSONObject result = new JSONObject();
        result.put("event", event.name());
        result.put("payload", payload);
        return result;
    }

    // createMessage() generates JSON wrapper that includes event name and payload
    public static JSON createMessage( String event,  JSON payload){
        JSONObject result = new JSONObject();
        result.put("event", event);
        result.put("payload", payload);
        return result;
    }

    // createMessage() generates JSON wrapper that includes event name and payload
    public static JSON createMessage( WebSocketEvents event,  JSON payload){
        // Can arguments be null or wrong?
        JSONObject result = new JSONObject();
        result.put("event", event.name());
        result.put("payload", payload);
        return result;
    }
}
