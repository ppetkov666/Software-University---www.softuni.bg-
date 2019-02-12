namespace Web_server_handmade.Server.Routing
{
    using Contracts;
    using Enums;
    using Handlers;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Text.RegularExpressions;

    public class ServerRouteConfig : IServerRouteConfig
    {
        private readonly IDictionary<HttpRequestMethod, IDictionary<string, IRoutingContext>> routes;

        public ServerRouteConfig(IAppRouteConfig appRouteConfig)
        {
            this.AnonymousPaths = new List<string>(appRouteConfig.AnonymousPaths);

            this.routes = new Dictionary<HttpRequestMethod, IDictionary<string, IRoutingContext>>();

            IEnumerable<HttpRequestMethod> availableMethods = Enum
                .GetValues(typeof(HttpRequestMethod))
                .Cast<HttpRequestMethod>();

            foreach (var method in availableMethods)
            {
                this.routes[method] = new Dictionary<string, IRoutingContext>();
            }

            this.InitializeRouteConfig(appRouteConfig);
        }

        public IDictionary<HttpRequestMethod, IDictionary<string, IRoutingContext>> Routes => this.routes;

        public ICollection<string> AnonymousPaths { get; private set; }

        private void InitializeRouteConfig(IAppRouteConfig appRouteConfig)
        {
            foreach (var registeredRoute in appRouteConfig.Routes)
            {
                HttpRequestMethod requestMethod = registeredRoute.Key;
                IDictionary<string, RequestHandler> routesWithHandlers = registeredRoute.Value;

                foreach (KeyValuePair<string,RequestHandler> routeWithHandler in routesWithHandlers)
                {
                    string route = routeWithHandler.Key;
                    RequestHandler handler = routeWithHandler.Value;

                    List<string> parameters = new List<string>();

                    string parsedRouteRegex = this.ParseRoute(route, parameters);

                    RoutingContext routingContext = new RoutingContext(handler, parameters);

                    this.routes[requestMethod].Add(parsedRouteRegex, routingContext);
                }
            }
        }

        private string ParseRoute(string route, List<string> parameters)
        {
            // if route is /  we set it to:  ^/$
            if (route == "/")
            {
                return "^/$";
            }

            StringBuilder result = new StringBuilder();

            result.Append("^/");

            //if the rouse is /user/details we want to make it ^/user/details/$
            // we split by '/'  and  the result will be:  ^userdetails$
            // if the route is /user/{(?<name>[a-z]+)} we wan to make it -> ^/user/(?<name>[a-z]+)$
            // and we want to get the parameter: name
            string[] tokens = route.Split(new[] { '/' }, StringSplitOptions.RemoveEmptyEntries);

            this.ParseTokens(tokens, parameters, result);

            return result.ToString();
        }

        private void ParseTokens(string[] tokens, List<string> parameters, StringBuilder result)
        {
            for (int i = 0; i < tokens.Length; i++)
            {
                string end = i == tokens.Length - 1 ? "$" : "/";
                string currentToken = tokens[i];

                if (!currentToken.StartsWith('{') && !currentToken.EndsWith('}'))
                {
                    result.Append($"{currentToken}{end}");
                    continue;
                }

                Regex parameterRegex = new Regex("<\\w+>");
                Match parameterMatch = parameterRegex.Match(currentToken);

                if (!parameterMatch.Success)
                {
                    throw new InvalidOperationException($"Route parameter in '{currentToken}' is not valid.");
                }
                
                string match = parameterMatch.Value;
                String parameter = match.Substring(1, match.Length - 2);

                parameters.Add(parameter);

                string currentTokenWithoutCurlyBrackets = currentToken.Substring(1, currentToken.Length - 2);

                result.Append($"{currentTokenWithoutCurlyBrackets}{end}");
            }
        }
    }
}
