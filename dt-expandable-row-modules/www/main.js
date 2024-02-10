function mainTableCallback(table, eventId, idColumnIdx, uiColumnIdx){
  let container = table.tables().containers();
  let evtTarget = $(container).closest('.datatables');
  
  // unbind outputs every time some refresh happens in DT
  evtTarget.off('shiny:recalculating').on('shiny:recalculating', function(evt){
    // table refresh
    Shiny.unbindAll(evt.target);
  });
  
  table.on('preDraw', function(evt){
    // filtering, paging, sorting etc
    Shiny.unbindAll(evt.target);
  });
  
  table.on('click', 'td.dt-control', function (evt) {
    let tr = evt.target.closest('tr');
    let row = table.row(tr);
 
    if (row.child.isShown()) {
      Shiny.unbindAll(row.child());
      row.child.hide();
    } else {
      let rd = row.data();
      row.child(formatChildRow(rd, uiColumnIdx)).show();
      sendValueToBeckend(eventId, rd[idColumnIdx]); // module ID
      Shiny.bindAll(row.child());
    }
  });
}

function formatChildRow(d, uiColumnIdx) {
  return d[uiColumnIdx]; // module UI
}

function sendValueToBeckend(eventId, value){
  let payload = {
    value: value,
    timestamp: new Date() // make sure the event will be triggered (even if the same value is sent twice)
  };
  Shiny.setInputValue(eventId, payload);
}
