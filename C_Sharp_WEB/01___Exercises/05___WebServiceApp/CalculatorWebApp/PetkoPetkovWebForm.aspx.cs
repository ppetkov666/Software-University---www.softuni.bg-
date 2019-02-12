
namespace CalculatorWebApp
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Web;
    using System.Web.UI;
    using System.Web.UI.WebControls;

    public partial class PetkoPetkovWebForm : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            // if we add or change our webservice we have to update Calculatorservice in order to access new methods 
            // this has to be added into allowCookies="true"

            // what we are doing here is we are accesing web service though a proxy interface as we create an instance of 
            // this class and accessing his method ADD
            //We access web service using HTTP protocol and messages are exchanged with SOAP format
            //(SOAP is an XML-based protocol for accessing web services over HTTP)

            //the proxy class will prepare soap request message, will call the method Add,  web service will execute it and it will return 
            // Soap response back to the proxy class. the proxy will DE serialize the message and it will display it 
            //The process of serialization   and DE serialization is done by the Proxy class

            //visual studio generate proxy class using Web Service Description Language(WSDL) document of the web service
            //WSDL contains the methods, params and return types 
            CalculatorService.CalculatorWebServiceSoapClient client = new CalculatorService.CalculatorWebServiceSoapClient();
            lblResult.Text = client.Add(int.Parse(txtFirstNumber.Text), int.Parse(txtSecondNumber.Text)).ToString();

            gvCalculations.DataSource =  client.GetCalculations();
            gvCalculations.DataBind();
            gvCalculations.HeaderRow.Cells[0].Text = "Recent Calculations";
        }
    }
}