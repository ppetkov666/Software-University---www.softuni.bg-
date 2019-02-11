using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;

namespace WebServiceApp
{
    /// <summary>
    /// Summary description for CalculatorWebService
    /// </summary>
    [WebService(Namespace = "http://petkopetkov.org/webservices")]
    [WebServiceBinding(ConformsTo = WsiProfiles.None)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    public class CalculatorWebService : System.Web.Services.WebService
    {
        // webmethod attribute is mandatory if we want to use this method as a web service method
        [WebMethod(EnableSession =true, Description ="this method add 2 numbers", CacheDuration =20)]
        public int Add(int firstNumber, int secondNumber)
        {
            List<string> calculationResults;
            if (Session["CALCULATIONRESULTS"] == null)
            {
                calculationResults = new List<string>();
            }
            else
            {
                calculationResults = (List<string>)Session["CALCULATIONRESULTS"];
            }
            string strRecentCalculations = firstNumber.ToString() + " + " + secondNumber.ToString() + " = "
                 + (firstNumber + secondNumber).ToString();
            calculationResults.Add(strRecentCalculations);
            Session["CALCULATIONRESULTS"] = calculationResults;
            return firstNumber + secondNumber;
        }
        // [WebServiceBinding(ConformsTo = WsiProfiles.None)]
        [WebMethod(MessageName ="Add3Numbers")]
        public int Add(int firstNumber, int secondNumber, int thirdNumber)
        {
            return firstNumber + secondNumber + thirdNumber;
        }

        [WebMethod(EnableSession =true)]
        public List<string> GetCalculations()
        {
            if (Session["CALCULATIONRESULTS"] == null)
            {
                List<string> calculationresults = new List<string>();
                calculationresults.Add("You have not performed any calculations");
                return calculationresults;
            }
            else
            {
                return (List<string>)Session["CALCULATIONRESULTS"];
            }
        }
    }
}
