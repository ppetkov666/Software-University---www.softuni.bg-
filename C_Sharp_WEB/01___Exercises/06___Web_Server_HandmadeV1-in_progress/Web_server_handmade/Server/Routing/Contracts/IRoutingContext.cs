namespace Web_server_handmade.Server.Routing.Contracts
{
    using Handlers;
    using System.Collections.Generic;

    public interface IRoutingContext
    {
        //  it keeps params for example /user/create/{id}-is the parameter
        // //user/details/{moth}/{year} the last two are params
        IEnumerable<string> Parameters { get; }

        RequestHandler Handler { get; }
    }
}
