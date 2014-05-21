/** @jsx React.DOM */

var NetworkResources = React.createClass({
  render : function () {
    return <div className="container">
             <div className="row">
               <div className="col-md-12">
                 <div className="box">
                   <div className="box-header"><span className="title">Data Centers</span></div>
                   <div className="box-content">
                     <DataCenterList source="/datacenters" />
                   </div>
                 </div>
               </div>
             </div>
             <div className="row">
               <div className="col-md-12">
                 <div className="box">
                   <div className="box-header"><span className="title">Servers</span></div>
                   <div className="box-content">
                     <ServerList source="/servers" />
                   </div>
                 </div>
               </div>
             </div>
             <div className="row">
               <div className="col-md-12">
                 <div className="box">
                   <div className="box-header"><span className="title">IP Allocations</span></div>
                   <div className="box-content">
                     <IPAllocationList source="/ipallocations" />
                   </div>
                 </div>
               </div>
             </div>
           </div> ;
  }
}) ;

var DataCenterList = React.createClass({
  getInitialState : function () {
    return {
      data_centers : []
    } ;
  },

  componentDidMount: function () {
    $.ajax({
      type : 'GET',
      url : this.props.source,
      success : function(result) {
        this.setState({
          data_centers : result
        }) ;
        $(this.getDOMNode()).dataTable({
          bJQueryUI: false,
          bAutoWidth: false,
          sPaginationType: "full_numbers",
          sDom: "<\"table-header\"fl>t<\"table-footer\"ip>"
        }) ;
      }.bind(this)
    }) ;
  },

  render : function () {
    if (! this.state.data_centers.length) { // dont show a table without rows
      return <div></div> ;
    }
    var createItem = function(data_center) {
      return <DataCenterRow 
               key={data_center.id} 
               name={data_center.name} 
               website={data_center.website} 
               login={data_center.login} 
               password={data_center.password} 
               created={data_center.created} /> ;
    };
    return <table className="dTable responsive">
             <thead>
             <tr>
               <th><div>Name</div></th>
               <th><div>Website</div></th>
               <th><div>Login</div></th>
               <th><div>Password</div></th>
               <th><div>Created</div></th>
             </tr>
             </thead>
             <tbody>
             {this.state.data_centers.map(createItem)}
             </tbody>
           </table> ;
  }
}) ;

var DataCenterRow = React.createClass({
  render : function () {
    return <tr>
             <td>{this.props.name}</td>
             <td>{this.props.website}</td>
             <td>{this.props.login}</td>
             <td>{this.props.password}</td>
             <td>{moment.unix(this.props.created).format('YYYY-MM-DD')}</td>
           </tr> ;
  }
}) ;

var ServerList = React.createClass({
  getInitialState : function () {
    return {
      servers : []
    } ;
  },

  componentDidMount: function () {
    $.ajax({
      type : 'GET',
      url : this.props.source,
      success : function(result) {
        this.setState({
          servers : result
        });
        $(this.getDOMNode()).dataTable({
          bJQueryUI: false,
          bAutoWidth: false,
          sPaginationType: "full_numbers",
          sDom: "<\"table-header\"fl>t<\"table-footer\"ip>"
        }) ;
      }.bind(this)
    }) ;
  },

  render : function () {
    if (! this.state.servers.length) { // dont show a table without rows
      return <div></div> ;
    }
    var createItem = function(server) {
      return <tr key={server.id}>
               <td>{server.hostname}</td>
               <td>{server.ip_addr}</td>
               <td>{accounting.formatMoney(server.monthly_cost)}</td>
               <td>{moment.unix(server.created).format('YYYY-MM-DD')}</td>
             </tr> ;
    };
    return <table className="dTable responsive">
             <thead>
             <tr>
               <th><div>Hostname</div></th>
               <th><div>IP Address</div></th>
               <th><div>Monthly Cost</div></th>
               <th><div>Created</div></th>
             </tr>
             </thead>
             <tbody>
             {this.state.servers.map(createItem)}
             </tbody>
           </table> ;
  }
}) ;

var IPAllocationList = React.createClass({
  getInitialState : function () {
    return {
      ip_allocations : []
    } ;
  },

  componentDidMount: function () {
    $.ajax({
      type : 'GET',
      url : this.props.source,
      success : function(result) {
        this.setState({
          ip_allocations : result
        });
        $(this.getDOMNode()).dataTable({
          bJQueryUI: false,
          bAutoWidth: false,
          sPaginationType: "full_numbers",
          sDom: "<\"table-header\"fl>t<\"table-footer\"ip>"
        }) ;
      }.bind(this)
    }) ;
  },

  render : function () {
    if (! this.state.ip_allocations.length) { // dont show a table without rows
      return <div></div> ;
    }
    var createItem = function(ip_allocation) {
      return <tr key={ip_allocation.id}>
               <td>{ip_allocation.cidr}</td>
               <td>{accounting.formatMoney(ip_allocation.monthly_cost)}</td>
               <td>{moment.unix(ip_allocation.created).format('YYYY-MM-DD')}</td>
             </tr> ;
    };
    return <table className="dTable responsive">
             <thead>
             <tr>
               <th><div>CIDR</div></th>
               <th><div>Monthly Cost</div></th>
               <th><div>Created</div></th>
             </tr>
             </thead>
             <tbody>
             {this.state.ip_allocations.map(createItem)}
             </tbody>
           </table> ;
  }
}) ;

