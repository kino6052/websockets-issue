package com.isonas.web;

import javax.websocket.server.ServerEndpoint;

import org.slf4j.LoggerFactory;

import java.util.logging.Logger;
import java.util.logging.Level;
import javax.json.JsonReader;
import javax.json.JsonObject;
import java.io.StringReader;
import javax.websocket.*;
import javax.json.Json;
import com.isonas.service.WebSocketService.WebSocketActions;

/**
 * Created by kiril on 9/30/2016.
 */

@ServerEndpoint("/actions")
public class WebSocketServerEndpoint {
    static private final org.slf4j.Logger logger = LoggerFactory.getLogger(WebSocketServerEndpoint.class);


    @OnOpen
    public void open(Session session) {
        WebSocketSessionHandler.addSession(session);
    }

    @OnClose
    public void close(Session session) {
        WebSocketSessionHandler.removeSession(session);
    }

    @OnError
    public void onError(Throwable error) {
        //Logger.getLogger(WebSocketServerEndpoint.class.getName()).log(Level.SEVERE, null, error);
    }

    @OnMessage
    public void handleMessage(String message, Session session) {
        try (JsonReader reader = Json.createReader(new StringReader(message))) {
            JsonObject jsonMessage = reader.readObject();
            Long userId = null;
            Long tenantId = null;
            switch (WebSocketActions.valueOf(jsonMessage.getString("action"))){
                case SaveUserId:
                    userId = getUserId(jsonMessage);
                    tenantId = getTenantId(jsonMessage);
                    Long userIdKey = WebSocketSessionHandler.saveUserId(userId, session);
                    Long tenantUserKey = WebSocketSessionHandler.saveTenantUser(tenantId, userId);
                    WebSocketSessionHandler.updateUserSessionKeys(session, tenantUserKey, userIdKey); // Needed for Making Weak Maps Keep Their Keys if Session is Currently Active
            }
        } catch (Exception e) {
            logger.error(e.toString());
        }
    }

    private Long getUserId(JsonObject jsonMessage) {
        Long userId = null;
        try {
            userId = Long.parseLong(((Integer) jsonMessage.getInt("userId")).toString());
            return userId;
        } catch (Exception e) {
            logger.error(e.getMessage());
            return userId;
        }
    }

    private Long getTenantId(JsonObject jsonMessage) {
        Long tenantId = null;
        try {
            tenantId = Long.parseLong(((Integer) jsonMessage.getInt("tenantId")).toString());
            return tenantId;
        } catch (Exception e) {
            logger.error(e.getMessage());
            return tenantId;
        }
    }
}