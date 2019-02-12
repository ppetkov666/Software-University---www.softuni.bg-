namespace Web_server_handmade
{
    using System;
    using Server;
    using Server.Contracts;
    using Server.Routing;
    using Web_server_handmade.Application;

    public class StartUp : IRunnable
    {
        public static void Main()
        {
            new StartUp().Run();
        }

        public void Run()
        {
            MainApplication mainApplication = new MainApplication();
            AppRouteConfig appRouteConfig = new AppRouteConfig();
            mainApplication.Configure(appRouteConfig);
            

            WebServer webServer = new WebServer(1337,appRouteConfig);
            webServer.Run();
        }
    }
}
