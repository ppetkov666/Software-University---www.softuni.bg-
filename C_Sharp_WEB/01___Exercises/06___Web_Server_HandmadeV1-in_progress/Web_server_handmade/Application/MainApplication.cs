namespace Web_server_handmade.Application
{
    using Server.Contracts;
    using Controllers;
    using Server.Routing.Contracts;
    

    public class MainApplication : IApplication
    {
        public void Configure(IAppRouteConfig appRouteConfig)
        {
            appRouteConfig.Get(
                "/",
                req => new HomeController().Index());

            //appRouteConfig.Get(
            //    "/testsession",
            //    req => new HomeController().SessionTest(req));

            appRouteConfig.Get(
                "/users/{(?<name>[a-z]+)}",
                req => new HomeController().Index());
        }
    }
}
