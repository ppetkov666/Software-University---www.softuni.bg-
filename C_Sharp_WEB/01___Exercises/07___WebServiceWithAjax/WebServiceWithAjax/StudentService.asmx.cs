using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
namespace WebServiceWithAjax
{
    /// <summary>
    /// Summary description for StudentService
    /// </summary>
    [WebService(Namespace = "http://PetkoPetkov.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    [System.Web.Script.Services.ScriptService]
    public class StudentService : System.Web.Services.WebService
    {

        [WebMethod]
        public Student GetStudentById(string id)
        {
            string cs = ConfigurationManager.ConnectionStrings["DbConnection"].ConnectionString;
            using (SqlConnection db = new SqlConnection(cs))
            {
                SqlCommand command = new SqlCommand("spgetStudentbyId", db);
                command.CommandType = CommandType.StoredProcedure;
                SqlParameter param = new SqlParameter("@Id", id);
                command.Parameters.Add(param);
                Student student = new Student();
                db.Open();
                SqlDataReader reader = command.ExecuteReader();
                while (reader.Read())
                {
                    student.Id = Convert.ToInt32(reader["Id"]);
                    student.Name = reader["Name"].ToString();
                    student.Gender = reader["Gender"].ToString();
                    student.TotalMarks = Convert.ToInt32(reader["TotalMarks"]);
                }
                return student;
            }
        }
    }
}
