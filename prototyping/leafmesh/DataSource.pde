class DataSource {
  String url;
  ArrayList<PVector> dataSeries;
  PVector min;
  PVector max;
  
  DataSource(String url) {
    this.url = url;
    this.dataSeries = new ArrayList<PVector>();
    
    JSONArray data = loadJSONObject("moisturedata.json").getJSONArray("results");
    println(data.size() + " entries in data source " + this.url);
    
    for(int i = 0; i < data.size(); i++) {
      JSONObject entry = data.getJSONObject(i);
      int t = entry.getInt("t_utc");
      float m = entry.getFloat("moisture");
      this.dataSeries.add(new PVector(t, m));
      
      // find min max for both t & m values
      if(i == 0) {
        this.min = new PVector(t, m);
        this.max = new PVector(t, m);
      }
      else {
        if(t < min.x)
          min.x = t;
        else if(t > max.x)
          max.x = t;
        
        if(m < min.y)
          min.y = m;
        else if(m > max.y)
          max.y = m;
      }
    }
  }
  
  PVector getNext() {
    return this.dataSeries.get(frameCount%dataSeries.size()); // use frameCount as counter
  }
}
