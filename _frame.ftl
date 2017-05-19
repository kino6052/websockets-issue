[#if _r.user??]
[#-- If /sysadmin/, we bypass the _frame.ftl and load directly the targeted template --]
    [#if piStarts("/sysadmin/")]
        [#if _r.user.userAccessContext.hasRolePrivileges("SystemAdministrator")]
            [@includeFrameContent /]
        [#else]
            [@includeTemplate name="404.ftl" /]
        [/#if]
    [#-- if we have a user in the request, we display the application --]
    [#else]
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <link rel="icon" href="${_r.contextPath}/favicon.png">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1.0,minimum-scale=1.0"/>
        <title>Isonas Application</title>

        <script type="text/javascript">
            var contextPath = "${_r.contextPath}";
        </script>
        <link rel="stylesheet" href="${_r.contextPath}/bootstrap/css/bootstrap.min.css" type="text/css"/>
        <link href="${_r.contextPath}/_common/css/app-bundle.css?${.now?string('yyyyMMddHHmmss')}" rel="stylesheet">
        <link href="${_r.contextPath}/css/app-bundle.css?${.now?string('yyyyMMddHHmmss')}" rel="stylesheet">
        <style>
            /*
 _____   _           _         _                        _
|_   _| | |         | |       | |                      | |
  | |   | |__   __ _| |_ ___  | |_ ___  _ __ ___   __ _| |_ ___   ___  ___
  | |   | '_ \ / _` | __/ _ \ | __/ _ \| '_ ` _ \ / _` | __/ _ \ / _ \/ __|
 _| |_  | | | | (_| | ||  __/ | || (_) | | | | | | (_| | || (_) |  __/\__ \
 \___/  |_| |_|\__,_|\__\___|  \__\___/|_| |_| |_|\__,_|\__\___/ \___||___/

Oh nice, welcome to the stylesheet of dreams.
It has it all. Classes, ID's, comments...the whole lot:)
Enjoy responsibly!
@ihatetomatoes

*/

            /* ==========================================================================
               Chrome Frame prompt
               ========================================================================== */

            .chromeframe {
                margin: 0.2em 0;
                background: #ccc;
                color: #000;
                padding: 0.2em 0;
            }

            /* ==========================================================================
               Author's custom styles
               ========================================================================== */
            p {
                line-height: 1.33em;
                color: #7E7E7E;
            }
            h1 {
                color: #EEEEEE;
            }

            #loader-wrapper {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                z-index: 1000;
            }
            #loader {
                display: block;
                position: relative;
                left: 50%;
                top: 50%;
                width: 150px;
                height: 150px;
                margin: -50px 0 0 -50px;
                /* Chrome, Firefox 16+, IE 10+, Opera */

                z-index: 1001;
            }


            #loader-wrapper .loader-section {
                position: fixed;
                top: 0;
                width: 51%;
                height: 100%;
                background: white;
                z-index: 1000;
                -webkit-transform: translateX(0);  /* Chrome, Opera 15+, Safari 3.1+ */
                -ms-transform: translateX(0);  /* IE 9 */
                transform: translateX(0);  /* Firefox 16+, IE 10+, Opera */
            }

            #loader-wrapper .loader-section.section-left {
                left: 0;
            }

            #loader-wrapper .loader-section.section-right {
                right: 0;
            }

            /* Loaded */
            .loaded #loader-wrapper .loader-section.section-left {
                -webkit-transform: translateX(-100%);  /* Chrome, Opera 15+, Safari 3.1+ */
                -ms-transform: translateX(-100%);  /* IE 9 */
                transform: translateX(-100%);  /* Firefox 16+, IE 10+, Opera */

                -webkit-transition: all 0.7s 0.3s cubic-bezier(0.645, 0.045, 0.355, 1.000);
                transition: all 0.7s 0.3s cubic-bezier(0.645, 0.045, 0.355, 1.000);
            }

            .loaded #loader-wrapper .loader-section.section-right {
                -webkit-transform: translateX(100%);  /* Chrome, Opera 15+, Safari 3.1+ */
                -ms-transform: translateX(100%);  /* IE 9 */
                transform: translateX(100%);  /* Firefox 16+, IE 10+, Opera */

                -webkit-transition: all 0.7s 0.3s cubic-bezier(0.645, 0.045, 0.355, 1.000);
                transition: all 0.7s 0.3s cubic-bezier(0.645, 0.045, 0.355, 1.000);
            }

            .loaded #loader {
                opacity: 0;
                -webkit-transition: all 0.3s ease-out;
                transition: all 0.3s ease-out;
            }
            .loaded #loader-wrapper {
                visibility: hidden;

                -webkit-transform: translateY(-100%);  /* Chrome, Opera 15+, Safari 3.1+ */
                -ms-transform: translateY(-100%);  /* IE 9 */
                transform: translateY(-100%);  /* Firefox 16+, IE 10+, Opera */

                -webkit-transition: all 0.3s 1s ease-out;
                transition: all 0.3s 1s ease-out;
            }

            /* JavaScript Turned Off */
            .no-js #loader-wrapper {
                display: none;
            }
            .no-js h1 {
                color: #222222;
            }

            #content {
                margin: 0 auto;
                padding-bottom: 50px;
                width: 80%;
                max-width: 978px;
            }






            /* ==========================================================================
               Helper classes
               ========================================================================== */

            /*
             * Image replacement
             */

            .ir {
                background-color: transparent;
                border: 0;
                overflow: hidden;
                /* IE 6/7 fallback */
                *text-indent: -9999px;
            }

            .ir:before {
                content: "";
                display: block;
                width: 0;
                height: 150%;
            }

            /*
             * Hide from both screenreaders and browsers: h5bp.com/u
             */

            .hidden {
                display: none !important;
                visibility: hidden;
            }

            /*
             * Hide only visually, but have it available for screenreaders: h5bp.com/v
             */

            .visuallyhidden {
                border: 0;
                clip: rect(0 0 0 0);
                height: 1px;
                margin: -1px;
                overflow: hidden;
                padding: 0;
                position: absolute;
                width: 1px;
            }

            /*
             * Extends the .visuallyhidden class to allow the element to be focusable
             * when navigated to via the keyboard: h5bp.com/p
             */

            .visuallyhidden.focusable:active,
            .visuallyhidden.focusable:focus {
                clip: auto;
                height: auto;
                margin: 0;
                overflow: visible;
                position: static;
                width: auto;
            }

            /*
             * Hide visually and from screenreaders, but maintain layout
             */

            .invisible {
                visibility: hidden;
            }

            /*
             * Clearfix: contain floats
             *
             * For modern browsers
             * 1. The space content is one way to avoid an Opera bug when the
             *    `contenteditable` attribute is included anywhere else in the document.
             *    Otherwise it causes space to appear at the top and bottom of elements
             *    that receive the `clearfix` class.
             * 2. The use of `table` rather than `block` is only necessary if using
             *    `:before` to contain the top-margins of child elements.
             */

            .clearfix:before,
            .clearfix:after {
                content: " "; /* 1 */
                display: table; /* 2 */
            }

            .clearfix:after {
                clear: both;
            }

            /*
             * For IE 6/7 only
             * Include this rule to trigger hasLayout and contain floats.
             */

            .clearfix {
                *zoom: 1;
            }

            /* ==========================================================================
               EXAMPLE Media Queries for Responsive Design.
               These examples override the primary ('mobile first') styles.
               Modify as content requires.
               ========================================================================== */

            @media only screen and (min-width: 35em) {
                /* Style adjustments for viewports that meet the condition */
            }

            @media print,
            (-o-min-device-pixel-ratio: 5/4),
            (-webkit-min-device-pixel-ratio: 1.25),
            (min-resolution: 120dpi) {
                /* Style adjustments for high resolution devices */
            }

            /* ==========================================================================
               Print styles.
               Inlined to avoid required HTTP connection: h5bp.com/r
               ========================================================================== */

            @media print {
                * {
                    background: transparent !important;
                    color: #000 !important; /* Black prints faster: h5bp.com/s */
                    box-shadow: none !important;
                    text-shadow: none !important;
                }

                a,
                a:visited {
                    text-decoration: underline;
                }

                a[href]:after {
                    content: " (" attr(href) ")";
                }

                abbr[title]:after {
                    content: " (" attr(title) ")";
                }

                /*
                 * Don't show links for images, or javascript/internal links
                 */

                .ir a:after,
                a[href^="javascript:"]:after,
                a[href^="#"]:after {
                    content: "";
                }

                pre,
                blockquote {
                    border: 1px solid #999;
                    page-break-inside: avoid;
                }

                thead {
                    display: table-header-group; /* h5bp.com/t */
                }

                tr,
                img {
                    page-break-inside: avoid;
                }

                img {
                    max-width: 100% !important;
                }

                @page {
                    margin: 0.5cm;
                }

                p,
                h2,
                h3 {
                    orphans: 3;
                    widows: 3;
                }

                h2,
                h3 {
                    page-break-after: avoid;
                }
            }

            /*
                Ok so you have made it this far, that means you are very keen to on my code.
                Anyway I don't really mind it. This is a great way to learn so you actually doing the right thing:)
                Follow me @ihatetomatoes
            */
        </style>
        <!-- Library Requirements -->
        <script type="text/javascript" src="${_r.contextPath}/_common/js/lib-bundle.js"></script>
        <script type="text/javascript" src="${_r.contextPath}/_common/js/app-bundle.js?${.now?string('yyyyMMddHHmmss')}"></script>
        <script type="text/javascript" src="${_r.contextPath}/_common/js/templates.js?${.now?string('yyyyMMddHHmmss')}"></script>
        <!-- /Library Requirements -->
        <!-- Library Requirements -->
        <script type="text/javascript" src="${_r.contextPath}/js/lib-bundle.js"></script>
        <script type="text/javascript" src="${_r.contextPath}/js/app-bundle.js?${.now?string('yyyyMMddHHmmss')}"></script>
        <script type="text/javascript" src="${_r.contextPath}/js/templates.js?n=${.now?string('yyyyMMddHHmmss')}"></script>
        <!-- /Library Requirements -->
        <script src="${_r.contextPath}/bootstrap/js/bootstrap.js" type="text/javascript"></script>
        <script type="text/javascript">
            var user = {
                id: ${_r.user.id},
                firstName: "${_r.user.firstName!""}",
                lastName: "${_r.user.lastName!""}",
                mi: "${_r.user.mi!""}",
                username: "${_r.user.username}",
                profileId: "${_r.user.profileId!""}",
                sys: [#if _r.user.userAccessContext.hasRolePrivileges("SystemAdministrator")]true[#else]false[/#if],
                uiStates: '${uiStates}'
            };

            var uac = {
                role: '${role!""}',
                privileges: '${privileges!""}',
                licenseTypes: '${licenseTypes!""}'
            };
            app.uac.init(uac);
            app.udac.init('${userAreas}');

            app.enums.init(decodeURIComponent('${enumInfos}'.replace(/\+/g, '%20')));
        </script>
        [#--Script Responsible for the WebSocket Functionality--]
        <script type="text/javascript" id="websockets">
            var globalSocket = null;
            var globalRefreshSockets = null;
            $(document).ready(function(){
                // Initialization
                var socket = null;
                var origin = window.location.origin;
                var tenantId = null;
                var url = "";
                var timer = 10; // Required to Refresh Websocket in Case Something Gets Stuck; // TODO: Find a Way to Intercept Ping/Pong Frames to Imrove Functionality

                // Start Timer to Make Sure That if Web Sockets Get Stuck, They Get Refreshed
                setInterval(
                    function(){
                        if (socket && timer <= 0) {
                            console.log("Refreshing Sockets");
                            $(document).trigger("REFRESH_WEBSOCKETS");
                            timer = 10;
                        }
                        timer -= 1;
                    },
                    1000
                );

                // Choose Correct Protocol
                var isHttps = function(origin) {
                    (/https/g).test(origin);
                };
                var replaceUrlSchema = function(origin) {
                    if (isHttps(origin)) {
                        return origin.replace("https", "wss");
                    } else {
                        return origin.replace("http", "ws");
                    }
                };

                // WebSocket Lifetime Events
                $(document).on("CLOSE_WEBSOCKETS", function(event){
                    closeWebSockets();
                });

                $(document).on("REFRESH_WEBSOCKETS", function(event){
                    refreshWebSockets();
                });

                $(document).on("SAVE_TENANT_ID_WEBSOCKETS", function(event, id){
                    tenantId = id;
                    if (
                        id && socket === null
                    ) {
                        refreshWebSockets();
                    }
                });

                function closeWebSockets() {
                    try {
                        socket.onclose = function(){}; // Prevent WebSockets from Refreshing
                        socket.close();
                    } catch (e) {
                        console.warn("Couldn't Close WebSockets");
                    }
                }

                function refreshWebSockets() {
                    url = replaceUrlSchema(origin);
                    url = url.concat("/actions");
                    closeWebSockets();
                    setTimeout(
                        function(){
                            socket = new WebSocket(url);
                            socket.onmessage = onMessage;
                            socket.onclose = onClose;
                        },
                        500
                    )
                }

                globalRefreshSockets = refreshWebSockets;

                // Realtime Events from Server
                function onMessage(event) {
                    timer = 10;
                    var message = JSON.parse(event.data);
                    if (app.enums.get("websocketEvents", "OnConnection").value === message.event){
                        socket.send(
                            JSON.stringify({
                                "action": app.enums.get("websocketActions", "SaveUserId").value,
                                "userId": ${_r.user.id},
                                "tenantId": tenantId
                            })
                        );
                    } else
                    if (
                        message.tenantId === tenantId
                    ) {
                        switch (message.event) {
                            // Accesspoint Status
                            case app.enums.get("websocketEvents", "OnAccesspointStatus").value:
                                $(document).trigger("DO_ACCESSPOINT_STATUS_UPDATE", message);
                                break;
                            // Closed Status (Door Open or Closed)
                            case app.enums.get("websocketEvents", "OnClosedStatus").value:
                                $(document).trigger("DO_CLOSED_STATUS_UPDATE", message);
                                break;
                            // Connection Status
                            case app.enums.get("websocketEvents", "OnConnectedStatus").value:
                                try {
                                    $(document).trigger("DO_CONNECTION_STATUS_UPDATE", message);
                                } catch (e) {
                                    console.warn("Couldn't Send DO_CONNECTION_STATUS_UPDATE");
                                }
                                break;
                            // Alerts
                            case app.enums.get("websocketEvents", "OnAlert").value:
                                $(document).trigger("DO_ALERT_UPDATE", message);
                                break;
                            // Kick Out Users Out of Their Session
                            case app.enums.get("websocketEvents", "OnSessionExpired").value:
                                app.realtime.sessionExpired = True
                        }
                    }
                }
                function onClose(event){
                    console.log("Websocket Connection Closed");
                }
            });
        </script>
        [#--Script Responsible for the WebSocket Functionality--]
        <script type="text/javascript" id="websockets">
            var globalSocket = null;
            var globalRefreshSockets = null;
            $(document).ready(function(){
                // Initialization
                var socket = null;
                var origin = window.location.origin;
                var tenantId = null;
                var url = "";
                var timer = 10; // Required to Refresh Websocket in Case Something Gets Stuck; // TODO: Find a Way to Intercept Ping/Pong Frames to Imrove Functionality

                // Start Timer to Make Sure That if Web Sockets Get Stuck, They Get Refreshed
                setInterval(
                        function(){
                            if (socket && timer <= 0) {
                                console.log("Refreshing Sockets");
                                $(document).trigger("REFRESH_WEBSOCKETS");
                                timer = 10;
                            }
                            timer -= 1;
                        },
                        1000
                );

                // Choose Correct Protocol
                var isHttps = function(origin) {
                    (/https/g).test(origin);
                };

                var replaceUrlSchema = function(origin) {
                    if (isHttps(origin)) {
                        return origin.replace("https", "wss");
                    } else {
                        return origin.replace("http", "ws");
                    }
                };

                // WebSocket Lifetime Events
                $(document).on("CLOSE_WEBSOCKETS", function(event){
                    closeWebSockets();
                });

                $(document).on("REFRESH_WEBSOCKETS", function(event){
                    refreshWebSockets();
                });

                $(document).on("SAVE_TENANT_ID_WEBSOCKETS", function(event, id){
                    tenantId = id;
                    if (
                            id && socket === null
                    ) {
                        refreshWebSockets();
                    }
                });

                function closeWebSockets() {
                    try {
                        socket.onclose = function(){}; // Prevent WebSockets from Refreshing
                        socket.close();
                    } catch (e) {
                        console.warn("Couldn't Close WebSockets");
                    }
                }

                function refreshWebSockets() {
                    url = replaceUrlSchema(origin);
                    url = url.concat("/history");
                    closeWebSockets();
                    setTimeout(
                            function(){
                                socket = new WebSocket(url);
                                socket.onmessage = onMessage;
                                socket.onclose = onClose;
                            },
                            500
                    )
                }

                globalRefreshSockets = refreshWebSockets;

                // Realtime Events from Server
                function onMessage(event) {
                    timer = 10;
                    var message = JSON.parse(event.data);
                    if (app.enums.get("websocketEvents", "OnConnection").value === message.event){
                        socket.send(
                                JSON.stringify({
                                    "action": app.enums.get("websocketActions", "SaveUserId").value,
                                    "userId": ${_r.user.id},
                                    "tenantId": tenantId
                                })
                        );
                    } else
                    if (
                            message.tenantId === tenantId
                    ) {
                        switch (message.event) {
                                // Realtime Activity
                            case app.enums.get("websocketEvents", "OnActivity").value:
                                $(document).trigger("DO_ACTIVITY_UPDATE", message);
                                break;
                                // Accesspoint Status
                        }
                    }
                }
                function onClose(event){
                    console.log("Websocket Connection Closed");
                }
            });
        </script>
    </head>
    <body>
    <div id="loader-wrapper">
        <div id="loader">
            <svg width="325" height="325" xmlns="http://www.w3.org/2000/svg">
                <path d="M403.88,196.563h-9.484v-44.388c0-82.099-65.151-150.681-146.582-152.145c-2.225-0.04-6.671-0.04-8.895,0
		C157.486,1.494,92.336,70.076,92.336,152.175v44.388h-9.485c-14.616,0-26.538,15.082-26.538,33.709v222.632
		c0,18.606,11.922,33.829,26.539,33.829h321.028c14.616,0,26.539-15.223,26.539-33.829V230.272
		C430.419,211.646,418.497,196.563,403.88,196.563z M273.442,341.362v67.271c0,7.703-6.449,14.222-14.158,14.222H227.45
		c-7.71,0-14.159-6.519-14.159-14.222v-67.271c-7.477-7.36-11.83-17.537-11.83-28.795c0-21.334,16.491-39.666,37.459-40.513
		c2.222-0.09,6.673-0.09,8.895,0c20.968,0.847,37.459,19.179,37.459,40.513C285.272,323.825,280.919,334.002,273.442,341.362z
		 M331.886,196.563h-84.072h-8.895h-84.072v-44.388c0-48.905,39.744-89.342,88.519-89.342c48.775,0,88.521,40.437,88.521,89.342
		V196.563z" fill="#51a1e0" transform="scale(0.07) translate(535, 520)"/>
                <path d="M10 55 A 45 45, 0, 1, 1, 55 100" stroke="#51a1e0" stroke-width="3" fill="none">
                    <animateTransform
                            attributeType="xml"
                            attributeName="transform"
                            type="rotate"
                            from="0 55 55"
                            to="360 55 55"
                            dur="1.2s"
                            repeatCount="indefinite"
                    />
                </path>
                <path d="M20 55 A 35 35, 0, 1, 1, 55 90" stroke="#51a1e0" stroke-width="3" fill="none">
                    <animateTransform
                            attributeType="xml"
                            attributeName="transform"
                            type="rotate"
                            from="360 55 55"
                            to="0 55 55"
                            dur="1.2s"
                            repeatCount="indefinite"
                    />
                </path>
            </svg>
        </div>

        <div class="loader-section section-left"></div>
        <div class="loader-section section-right"></div>
    </div>
    <div class="app_version">${version}</div>
    <div class="printable"></div>
        [@includeFrameContent /]

    </body>
    <script>
        $(document).ready(function() {
            setTimeout(function(){
                $('body').addClass('loaded');
                $('h1').css('color','#222222');
            }, 1000);
        });
    </script>
    </html>
    [/#if]
[#-- if no user, we include the loginpage --]
[#else]
    [#if piStarts("/register")]
        [@includeTemplate name="register.ftl"/]
    [#else]
        [#if piStarts("/reset_password")]
            [@includeTemplate name="reset_password.ftl"/]
        [#else]
            [#if piStarts("/callback")]
                [@includeTemplate name="callback.ftl"/]
            [#else]
                [@includeTemplate name="loginpage.ftl"/]
            [/#if]
        [/#if]
    [/#if]
[/#if]