namespace Web_server_handmade.Server.Routing
{
    using Contracts;
    using Enums;
    using Handlers;
    using Http.Contracts;
    using System;
    using System.Collections.Generic;
    using System.Linq;

    public class AppRouteConfig : IAppRouteConfig
    {
        private readonly Dictionary<HttpRequestMethod, IDictionary<string, RequestHandler>> routes;
       
        public AppRouteConfig()
        {
            this.AnonymousPaths = new List<string>();

            this.routes = new Dictionary<HttpRequestMethod, IDictionary<string, RequestHandler>>();
            
            IEnumerable<HttpRequestMethod> availableMethods = Enum
                .GetValues(typeof(HttpRequestMethod))
                .Cast<HttpRequestMethod>();

            foreach (HttpRequestMethod method in availableMethods)
            {
                this.routes[method] = new Dictionary<string, RequestHandler>();
            }
        }

        public IReadOnlyDictionary<HttpRequestMethod, IDictionary<string, RequestHandler>> Routes => this.routes;

        public ICollection<string> AnonymousPaths { get; private set; }

        public void Get(string route, Func<IHttpRequest, IHttpResponse> handler)
        {
            this.AddRoute(route, HttpRequestMethod.Get, new RequestHandler(handler));
        }

        public void Post(string route, Func<IHttpRequest, IHttpResponse> handler)
        {
            this.AddRoute(route, HttpRequestMethod.Post, new RequestHandler(handler));
        }
        // .AddRoute("/home",Get or Post, new GetHandler(request => new HomeController().Details))
        public void AddRoute(string route, HttpRequestMethod method, RequestHandler handler)
        {
            this.routes[method].Add(route, handler);
        }

    }
}
