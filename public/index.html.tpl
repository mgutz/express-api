<!DOCTYPE html>
<html>
<head>
  <title>${title}</title>
  <link href='https://fonts.googleapis.com/css?family=Droid+Sans:400,700' rel='stylesheet' type='text/css'/>
  <link href='css/reset.css' media='screen' rel='stylesheet' type='text/css'/>
  <link href='css/screen.css' media='screen' rel='stylesheet' type='text/css'/>
  <link href='css/reset.css' media='print' rel='stylesheet' type='text/css'/>
  <link href='css/screen.css' media='print' rel='stylesheet' type='text/css'/>
  <script type="text/javascript" src="lib/shred.bundle.js"></script>
  <script src='lib/jquery-1.8.0.min.js' type='text/javascript'></script>
  <script src='lib/jquery.slideto.min.js' type='text/javascript'></script>
  <script src='lib/jquery.wiggle.min.js' type='text/javascript'></script>
  <script src='lib/jquery.ba-bbq.min.js' type='text/javascript'></script>
  <script src='lib/handlebars-1.0.0.js' type='text/javascript'></script>
  <script src='lib/underscore-min.js' type='text/javascript'></script>
  <script src='lib/backbone-min.js' type='text/javascript'></script>
  <script src='lib/swagger.js' type='text/javascript'></script>
  <script src='swagger-ui.js' type='text/javascript'></script>
  <script src='lib/highlight.7.3.pack.js' type='text/javascript'></script>

  <!-- enabling this will enable oauth2 implicit scope support -->
  <script src='lib/swagger-oauth.js' type='text/javascript'></script>

  <script type="text/javascript">
    $(function () {
      window.swaggerUi = new SwaggerUi({
      url: '${schemaUrl}',
      dom_id: "swagger-ui-container",
      supportedSubmitMethods: ['get', 'post', 'put', 'delete'],
      onComplete: function(swaggerApi, swaggerUi){
        log("Loaded SwaggerUI");
        console.log('swaggerApi', swaggerApi);

        if(typeof initOAuth == "function") {
          /*
          initOAuth({
            clientId: "your-client-id",
            realm: "your-realms",
            appName: "your-app-name"
          });
          */
        }
        $('pre code').each(function(i, e) {
          hljs.highlightBlock(e)
        });
      },
      onFailure: function(data) {
        log("Unable to Load SwaggerUI");
      },
      docExpansion: "none"
    });

    function setClientCredentials() {
      var clientId = $('#client-id').val();
      var clientSecret = $('#client-secret').val();
      if (!clientId || !clientSecret) return;

      var url;
      try {
        url = window.swaggerUi.api.authSchemes.oauth2.grantTypes.client_credentials.tokenEndpoint.url;
      } catch(err) {}

      if (!url) {
        console.error('Could not get token endpoint from authorizations.oauth2.grantTypes.client_credentials.tokenEndpoint.url');
        return;
      }

      $.ajax({
        type: 'POST',
        url: url,
        data: {
            client_id: clientId,
            client_secret: clientSecret,
            grant_type: 'client_credentials',
            // TODO need to build drop down for this
            scope: 'rwx:verification'
        },
        error: function(xhr, status, error) {
          var $id = $('#client-id');
          var $secret = $('#client-secret');
          [$id, $secret].forEach(function($it) {
            $it.addClass('error');
            $it.removeClass('ok');
            $it.wiggle()
          });
          console.error('error setClientCredentials', error);
        },
        success: function(response){
          var timeoutMs = response.expires_in * 1000;
          var id = setTimeout(setClientCredentials, timeoutMs - 1000);
          var $id = $('#client-id');
          var $secret = $('#client-secret');
          [$id, $secret].forEach(function($it) {
            $it.removeClass('error');
            $it.addClass('ok');
          });
          var token = response.access_token;
          window.authorizations.add("key", new ApiKeyAuthorization("Authorization", "Bearer " + token, "header"));
        }
      });
    }

    $('#client-id').change(setClientCredentials);
    $('#client-secret').change(setClientCredentials);

    window.swaggerUi.load();
  });
  </script>
</head>

<body class="swagger-section">

<div id='header'>
  <div class="swagger-ui-wrap">
    <a id="logo" href="${docsUrl}">${company}</a>
    <form id='api_selector'>
      <div class='input'><input placeholder="Enter Client ID" id="client-id" name="clientId" type="text"/></div>
      <div class='input'><input placeholder="Enter Client Secret" id="client-secret" name="clientSecret" type="text"/></div>
    </form>
  </div>
</div>

<div id="message-bar" class="swagger-ui-wrap">&nbsp;</div>
<div id="swagger-ui-container" class="swagger-ui-wrap"></div>
</body>
</html>
