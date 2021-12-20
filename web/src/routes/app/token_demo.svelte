<script>

import { onMount } from 'svelte'
import * as d3 from 'd3';
  
onMount(async () => {

// Select the svg area
var svg2 = d3.select("#Viz_area")

// Create a scale: transform value in pixel
var x = d3.scaleLinear()
    .domain([0, 100])         // This is the min and the max of the data: 0 to 100 if percentages
    .range([0, 400]);       // This is the corresponding value I want in Pixel

/*svg.append("circle")
  .attr("cx", x(30)).attr("cy", 140).attr("r", 30).style("fill", "red");*/
  svg2.append("circle")
  .attr("cx", x(30)).attr("cy", 140).attr("r", 30).style("fill", "white").style("stroke", "red");
svg2.append("circle")
  .attr("cx", x(30)).attr("cy", 70).attr("r", 30).style("fill", "red");

svg2.append("circle")
  .attr("cx", x(70)).attr("cy", 140).attr("r", 30).style("fill", "red");
svg2.append("circle")
  .attr("cx", x(70)).attr("cy", 70).attr("r", 30).style("fill", "red");


// Add 3 dots for 0, 50 and 100%
svg2.append("circle")
  .attr("cx", x(37)).attr("cy", 100).attr("r", 35).style("fill", "blue");
svg2.append("circle")
  .attr("cx", x(64)).attr("cy", 100).attr("r", 35).style("fill", "blue");

svg2.append("circle")
  .attr("cx", x(50)).attr("cy", 100).attr("r", 40).style("fill", "green");



  

const width = 599
const height = 400
const duration = 100
const renderLink = d3.linkVertical().x(d => d.x).y(d => d.y)
const tree = d3.tree().size([width - 20, height - 20])
const Node = d3.hierarchy.prototype.constructor;
  const svg = d3.select("body").append("svg").attr("viewBox", [-10, -10, width, height]);



  const root = new Node();
  const nodes = [root];
  const links = [];

  tree(root);

  let link = svg.append("g")
      .attr("fill", "none")
      .attr("stroke", "#000")
    .selectAll(".link");

  let node = svg.append("g")
      .attr("stroke", "#fff")
      .attr("stroke-width", 2)
    .selectAll(".node");

  const interval = d3.interval(() => {
    if (nodes.length >= 50) return interval.stop();

    // Add a new node to a random parent.
    const parent = nodes[Math.random() * nodes.length | 0];
    const child = Object.assign(new Node(), {parent, depth: parent.depth + 1});
    if (parent.children) parent.children.push(child);
    else parent.children = [child];
    nodes.push(child);
    links.push({source: parent, target: child});

    // Recompute the layout.
    tree(root);

    // Add entering nodes in the parent’s old position.
    node = node.data(nodes);
    node.on("click", console.log);
    node = node.enter().append("circle")
        .attr("class", "node")
        .attr("r", 6)
        .attr("cx", d => d.parent ? d.parent.px : d.px = d.x)
        .attr("cy", d => d.parent ? d.parent.py : d.py = d.y)
        .on("mouseover", function(d) {
          d3.select(this).attr("r", 10);
        })
        .on("mouseout", function(d) {
          d3.select(this).attr("r", 6);
        })
        .merge(node);

    // Add entering links in the parent’s old position.
    link = link.data(links);
    link = link.enter().insert("path", ".node")
        .attr("class", "link")
        .attr("d", d => {
          const o = {x: d.source.px, y: d.source.py};
          return renderLink({source: o, target: o});
        })
      .merge(link);

    // Transition nodes and links to their new positions.
    const t = svg.transition()
        .duration(duration);

    link.transition(t)
        .attr("d", renderLink);

    node.transition(t)
        .attr("cx", d => d.px = d.x)
        .attr("cy", d => d.py = d.y);

    
  }, duration);

  // invalidation.then(() => interval.stop());

  svg.node();


})
</script>
<div class="flex justify-center items-center my-4">
  <span class="px-6 py-2">Ver como:</span>
  <div class="bg-gray-200 rounded-lg">
    
    <div class="inline-flex rounded-lg">
      <input type="radio" name="room_type" id="roomPrivate" checked hidden/>
      <label for="roomPrivate" class="radio text-center self-center py-2 px-4 rounded-lg cursor-pointer hover:opacity-75">Mandala</label>
    </div>
    <div class="inline-flex rounded-lg">
      <input type="radio" name="room_type" id="roomPublic" hidden/>
      <label for="roomPublic" class="radio text-center self-center py-2 px-4 rounded-lg cursor-pointer hover:opacity-75">Red</label>
    </div>
    <div class="inline-flex rounded-lg">
      <input type="radio" name="room_type" id="roomPublic" hidden/>
      <label for="roomPublic" class="radio text-center self-center py-2 px-4 rounded-lg cursor-pointer hover:opacity-75">Piramide</label>
    </div>
  </div>
</div>
<div>
  <svg id="Viz_area" height=200 width=450 class="mx-auto text-center"></svg>
</div>








<style>
    input:checked ~ .radio {
  color:white;
  background-color: green;
}

:global(.node) {
  cursor: pointer;
}
</style>
