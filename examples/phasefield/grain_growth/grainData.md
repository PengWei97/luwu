# unique_grains -  unique_region

## input
```bash
  [./unique_grains]
    type = FeatureFloodCountAux
    variable = unique_grains
    flood_counter = grain_tracker
    field_display = UNIQUE_REGION
    execute_on = 'initial timestep_end'
  [../]
```
## code: FeatureFloodCount::getEntityValue ??
```c++
  switch (field_type) 
  {
    case FieldType::UNIQUE_REGION: // unique_region
    {
      const auto entity_it = _feature_maps[var_index].find(entity_id); // _feature_maps[0]
        // std::vector<std::map<dof_id_type, int>> _feature_maps;
        // const struct std::_Rb_tree_const_iterator<std::pair<const long unsigned int, int> > entity_it
      // std::cout << "the type of entity_it is " << typeid(entity_it).name() << std::endl; // St23_Rb_tree_const_iteratorISt4pairIKmiEE
      // std::cout << "the size of _feature_maps is " << _feature_maps.size() << std::endl; // 8; op_num = 8
      // std::cout << "the size of _feature_maps[0] is " << _feature_maps[0] << std::endl; // 8; op_num = 8
      // std::cout << "the value of entity_id is " << entity_id << std::endl;
      // std::cout << "the value of var_index is " << var_index << std::endl;

      if (entity_it != _feature_maps[var_index].end())
        {
          // execute_on = 'initial timestep_end'
          return entity_it->second; // + _region_offsets[var_index];
        }
      else
        return -1;
    }
```

# FeatureVolumeVectorPostprocessor
## input
```bash
[VectorPostprocessors]
  [./grain_volumes] 
    type = FeatureVolumeVectorPostprocessor 
    flood_counter = grain_tracker # The FeatureFloodCount UserObject to get values from.
    execute_on = 'initial timestep_end'
    output_centroids = true
  [../]
[]
```

## code::FeatureVolumeVectorPostprocessor
