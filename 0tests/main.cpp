#include<iostream>
#include<vector>
using namespace std;
int main()
{
  //Initializing a 3D vector (name = vector_3d )with dimensions (2, 3, 4) and initializing each element with 1
//   vector<vector<vector<double> > > vector_3d(12, vector<vector<double> >(3, vector<double>(3, 0)));
//   cout << vector_3d.size() << std::endl;

//   vector_3d[0][0][0] = -0.5;

//   cout << vector_3d[0][0][0] << std::endl;

  vector<vector<vector<double> > > vector_3d = {
    {{1.0, 0.0, 0.0}, {0.0, 1.0, 0.0}, {0.0, 0.0, 1.0}}, // 1
    {{-0.5, 0.866, 0.0}, {-0.866, 0.5, 0.0}, {0.0, 0.0, 1.0}}, // 2
    {{-0.5, -0.866, 0.0}, {0.866, -0.5, 0.0}, {0.0, 0.0, 1.0}}, // 3
    {{0.5, 0.866, 0.0}, {-0.866, 0.5, 0.0}, {0.0, 0.0, 1.0}}, // 4
    {{-1.0, 0.0, 0.0}, {0.0, -1.0, 0.0}, {0.0, 0.0, 1.0}}, // 5
    {{0.5, -0.866, 0.0}, {0.866, 0.5, 0.0}, {0.0, 0.0, 1.0}}, // 6
    {{-0.5, -0.866, 0.0}, {-0.866, 0.5, 0.0}, {0.0, 0.0, 1.0}}, // 7
    {{1.0, 0.0, 0.0}, {0.0, -1.0, 0.0}, {0.0, 0.0, -1.0}}, // 8
    {{-0.5, 0.866, 0.0}, {0.866, 0.5, 0.0}, {0.0, 0.0, 1.0}}, // 9
    {{0.5, 0.866, 0.0}, {0.866, -0.5, 0.0}, {0.0, 0.0, -1.0}}, // 10
    {{-1.0, 0, 0.0}, {0.0, 1.0, 0.0}, {0.0, 0.0, -1.0}}, // 11
    {{0.5, -0.866, 0.0}, {-0.866, -0.5, 0.0}, {0.0, 0.0, -1.0}}, // 12
  };
  //Printing 3D vector
  for(int i=0;i<vector_3d.size();i++)
  {
    cout << "i " << i +1 << endl;
    for(int j=0;j<vector_3d[i].size();j++)
    {
      for(int k=0;k<vector_3d[i][j].size();k++)
      {
        cout<<vector_3d[i][j][k]<<" ";
      }
      cout<<endl;
    }
    cout<<endl;
  }
  return 0;
}