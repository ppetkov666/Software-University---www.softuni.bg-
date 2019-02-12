namespace Web_server_handmade.Server.Handlers
{
    using Common;
    using Contracts;
    using Http.Contracts;
    using Http.Response;
    using Enums;
    using Routing.Contracts;
    using Server.Http;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text.RegularExpressions;

    public class HttpHandler : IRequestHandler
    {
        private readonly IServerRouteConfig serverRouteConfig;

        public HttpHandler(IServerRouteConfig routeConfig)
        {
            CoreValidator.ThrowIfNull(routeConfig, nameof(routeConfig));

            this.serverRouteConfig = routeConfig;
        }

        public IHttpResponse Handle(IHttpContext context)
        {
            try
            {
                // Check if user is authenticated
                ICollection<string> anonymousPaths = this.serverRouteConfig.AnonymousPaths;

                //if (!anonymousPaths.Contains(context.Request.Path) &&
                //    (context.Request.Session == null || !context.Request.Session.Contains(SessionStore.CurrentUserKey)))
                //{
                //    return new RedirectResponse(anonymousPaths.First());
                //}

                HttpRequestMethod requestMethod = context.Request.Method;
                string requestPath = context.Request.Path;
                IDictionary<string,IRoutingContext> registeredRoutes = this.serverRouteConfig.Routes[requestMethod];

                foreach (var registeredRoute in registeredRoutes)
                {
                    string routePattern = registeredRoute.Key;
                    IRoutingContext routingContext = registeredRoute.Value;

                    Regex routeRegex = new Regex(routePattern);
                    Match match = routeRegex.Match(requestPath);

                    if (!match.Success)
                    {
                        continue;
                    }

                    IEnumerable<string> parameters = routingContext.Parameters;

                    foreach (string parameter in parameters)
                    {
                        string parameterValue = match.Groups[parameter].Value;
                        context.Request.AddUrlParameter(parameter, parameterValue);
                    }

                    return routingContext.Handler.Handle(context);
                }
            }
            catch (Exception ex)
            {
                return new InternalServerErrorResponse(ex);
            }

            return new NotFoundResponse();
        }
    }
}
