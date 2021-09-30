


Each gltf has:
a 'scene' which specifies which of the 'scenes' to load first
each 'scene' has a number of 'meshes'
each 'mesh' has a number of 'primitives'
each 'primitive' has one 'material'
each 'material' may be a 'texture' material (or it could be a shader or something else)
each 'texture' has an 'image'
primitives and images may point to 'accessors' or 'bufferViews' which are used to get data from the 'buffer'
the 'buffer' is a very large base64 encoded string with all the binary data (eg - vertexes and images)
