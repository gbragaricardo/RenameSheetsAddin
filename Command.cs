using System.Windows;
using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using Application = Autodesk.Revit.ApplicationServices.Application;

namespace RenameSheets.Addin;

[Transaction(TransactionMode.Manual)]
public class Command : IExternalCommand
{
    public Result Execute(ExternalCommandData commandData, ref string message, ElementSet elements)
    {
        UIApplication uiApp = commandData.Application;
        UIDocument uiDoc = uiApp.ActiveUIDocument;
        Application app = uiApp.Application;
        Document doc = uiDoc.Document;

        RenameWindow renameWindow = new RenameWindow();
        renameWindow.ShowDialog();

        string inputRenamePattern = renameWindow.RenamePatternTextBox.Text;

        var allDocumentSheets = new FilteredElementCollector(doc)
            .OfCategory(BuiltInCategory.OST_Sheets)
            .WhereElementIsNotElementType()
            .Cast<ViewSheet>()
            .ToList();

        using Transaction transaction = new Transaction(doc, "Renomear Folhas (BIM)");
        transaction.Start();

        foreach (var sheet in allDocumentSheets)
        {
            string sheetNumber = sheet.SheetNumber;
            string formattedName = inputRenamePattern.Replace("@", sheetNumber);
            sheet.Name = formattedName;
        }

        transaction.Commit();

        return Result.Succeeded;
    }
}
