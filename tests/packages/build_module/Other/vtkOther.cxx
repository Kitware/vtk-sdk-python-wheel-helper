#include "vtkOther.h"

#include <vtkObjectFactory.h>

//---------------------------------------------------------------------------
vtkStandardNewMacro(vtkOther)

//---------------------------------------------------------------------------
vtkOther::vtkOther()
{

}

//---------------------------------------------------------------------------
vtkOther::~vtkOther()
{
  
}

//---------------------------------------------------------------------------
void vtkOther::PrintSelf(ostream& os, vtkIndent indent)
{
  this->Superclass::PrintSelf(os, indent);
  os << indent << "vtkOther: " << this->GetClassName() << "\n";
}
