// SPDX-FileCopyrightText: Copyright (c) Ken Martin, Will Schroeder, Bill Lorensen
// SPDX-License-Identifier: BSD-3-Clause
#include "vtkDummy.h"
#include "vtkObjectFactory.h"

#include <Dependency.hpp>

//------------------------------------------------------------------------------
vtkStandardNewMacro(vtkDummy);

//------------------------------------------------------------------------------
void vtkDummy::PrintSelf(ostream& os, vtkIndent indent)
{
  os << indent << "vtkDummy:\n";
  os << indent << "  Dependency: " << Dependency::something() << std::endl;
  this->Superclass::PrintSelf(os, indent.GetNextIndent());
}
