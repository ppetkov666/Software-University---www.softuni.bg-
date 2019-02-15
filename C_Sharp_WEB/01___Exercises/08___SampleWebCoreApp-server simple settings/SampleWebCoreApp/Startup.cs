using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using SampleWebCoreApp.Services;
namespace SampleWebCoreApp
{
    public class Startup
    {
        // This method gets called by the runtime. Use this method to add services to the container.
        // For more information on how to configure your application, visit https://go.microsoft.com/fwlink/?LinkID=398940
        public void ConfigureServices(IServiceCollection services)
        {
            // i register all interfaces to what class will be registered
            // with other words - when someone want instanse of this interface i want to return always the same class
            services.AddSingleton<IMyservice, MyService>();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            // if the project is started in development mode give me the full page exception in html
            // this is the first middleware 
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.Use(async (context, next) =>
            {
                context.Response.Headers.Add("Content-Type", "text/html");
                await next();
            });

            // to detect it as query in the broser - '?'and then search
            app.MapWhen(ctx => ctx.Request.Query.ContainsKey("search"), searchApp =>
            {
                searchApp.Use(async (context, next) =>
                {
                    context.Response.Headers.Add("My-Custom-Header", "Random Value");
                    await next();
                });
                searchApp.Run(async (context) =>
                {
                    await context.Response.WriteAsync("searching");
                });
            });

            app.Map("/dogs", dogArea =>
             {
                 dogArea.Run(async (context) =>
                 {
                     await context.Response.WriteAsync("this is dog area");
                 });
             });

            app.Use(async (context, next) =>
            {
                if (context.Request.Path.Value.StartsWith("/users"))
                {
                    await context.Response.WriteAsync("<h3>this is user area</h3>");
                }
                await next();
            });

            // it is the last step which our app start and complete the pipeline
            app.Run(async (context) =>
            {
                IMyservice service = context.RequestServices.GetService<IMyservice>();

                Console.WriteLine($"{context.Request.Method} - {context.Request.Path}");
                await context.Response.WriteAsync("<h1>hello from asp.net core</h1>");
                await context.Response.WriteAsync($"<h1>{service.Name}</h1>");

            });
        }
    }
}
