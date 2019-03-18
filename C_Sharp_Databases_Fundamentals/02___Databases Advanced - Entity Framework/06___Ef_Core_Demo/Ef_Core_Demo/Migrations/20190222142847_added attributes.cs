using Microsoft.EntityFrameworkCore.Migrations;

namespace Ef_Core_Demo.Migrations
{
    public partial class addedattributes : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "FirstName",
                table: "Employees",
                nullable: false,
                oldClrType: typeof(string),
                oldNullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "FirstName",
                table: "Employees",
                nullable: true,
                oldClrType: typeof(string));
        }
    }
}
