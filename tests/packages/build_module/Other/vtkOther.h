#ifndef __vtkOther_h
#define __vtkOther_h

// Dummy includes
#include "vtkDummy.h"
#include "vtkOtherModule.h"

class VTKOTHER_EXPORT vtkOther : public vtkDummy
{
public:
  static vtkOther* New();
  vtkTypeMacro(vtkOther, vtkDummy);
  void PrintSelf(ostream& os, vtkIndent indent) override;

protected:
  vtkOther();
  ~vtkOther() override;
};

#endif
