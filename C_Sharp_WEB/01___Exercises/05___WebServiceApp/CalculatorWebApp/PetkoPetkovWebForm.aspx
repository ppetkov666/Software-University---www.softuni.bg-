<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PetkoPetkovWebForm.aspx.cs" Inherits="CalculatorWebApp.PetkoPetkovWebForm" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <table style ="font-family:Arial">
            <tr>
                <td>
                    <b>First Number</b>
                </td>
                <td>
                    <asp:TextBox ID="txtFirstNumber" runat="server"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td>
                    <b>Second Number</b>
                </td>
                <td>
                    <asp:TextBox ID="txtSecondNumber" runat="server"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td>
                    <b>Result</b>
                </td>
                <td>
                    <asp:Label ID="lblResult" runat="server" ></asp:Label>
                </td>
            </tr>
            <tr>
                <td colspan ="2">
                    <asp:Button ID="btnAdd" runat="server" Text="ADD" OnClick="btnAdd_Click" />
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <asp:GridView ID="gvCalculations" runat="server"></asp:GridView>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
