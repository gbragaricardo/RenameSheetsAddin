using Autodesk.Revit.DB;
using Autodesk.Revit.UI;

namespace RenameSheets.Addin;

public class Command : IExternalCommand
{
    public Result Execute(ExternalCommandData commandData, ref string message, ElementSet elements)
    {
        return Result.Succeeded;
    }
}
