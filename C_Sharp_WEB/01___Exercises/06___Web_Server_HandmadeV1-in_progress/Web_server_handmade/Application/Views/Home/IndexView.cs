namespace Web_server_handmade.Application.Views.Home
{
    using Server.Contracts;

    public class IndexView : IView
    {
        public string View() => "<h1>Welcome mr. Petko Petkov!</h1>";
    }
}
