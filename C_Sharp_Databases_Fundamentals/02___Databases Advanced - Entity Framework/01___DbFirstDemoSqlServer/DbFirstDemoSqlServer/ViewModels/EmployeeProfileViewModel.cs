namespace DbFirstDemoSqlServer.ViewModels
{
    using DbFirstDemoSqlServer.Data.Models;
    public class EmployeeProfileViewModel
    {
        public EmployeeProfileViewModel(Employee employee)
        {
            this.FirstName = employee.FirstName;
            this.LastName = employee.LastName;
            this.JobTitle = employee.JobTitle;

        }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string JobTitle { get; set; }

        public override string ToString()
        {
            return $" I am {this.FirstName} {this.LastName} and i am {this.JobTitle}";
        }
    }
}
