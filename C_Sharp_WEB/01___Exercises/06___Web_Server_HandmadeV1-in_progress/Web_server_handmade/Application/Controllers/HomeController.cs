namespace Web_server_handmade.Application.Controllers
{
    using Server.Http.Contracts;
    using Server.Http.Response;
    using Views.Home;
    using Server.Enums;

    public class HomeController
    {
        // GET / 
        public IHttpResponse Index()
        {
            return new ViewResponse(HttpStatusCode.Ok, new IndexView());
        }
    }
}
