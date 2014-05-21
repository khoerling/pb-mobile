/** @jsx React.DOM */

$(function () {

  var mountPoint = document.getElementById('react-mount-point') ;

  // var AppRouter = Backbone.Router.extend({
  //   routes: {
  //     "": "dashboard",
  //   }
  // });
  // var router = new AppRouter ;
  // router.on('dashboard', function() {
  //   React.renderComponent(<Dashboard />, mountPoint) ;
  // }) ;

  // Backbone.history.start() ;

  React.renderComponent(<NetworkResources />, mountPoint) ;
}) ;
