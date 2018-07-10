//
//  UtilityMesh+skinning.h
//
//

#import "UtilityMesh.h"

/////////////////////////////////////////////////////////////////
// Type used to store vertex skinning attributes
typedef struct
{   
   GLKVector4 jointIndices; // 索引
   GLKVector4 jointWeights; // 权重
} 
UtilityMeshJointInfluence;


@interface UtilityMesh (skinning)

- (void)setJointInfluence:
      (UtilityMeshJointInfluence)aJointInfluence
   atIndex:(GLsizei)vertexIndex;

- (void)prepareToDrawWithJointInfluence;

@end
