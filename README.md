# Mi Querída Catamarca!  
## Sitio werb personal alojado en GitHub

### Temas del Sitio Web

- Cultura
- Gastronomía
- Historia
- Leyendas
- Contacto

:earth_americas: El sitio también esta alojado en [site44.com](https://dpsa.site44.com/).

```js
var server = require('http').createServer();
var io = require('socket.io')(server);
io.on('connection', function(client){
  client.on('event', function(data){});
  client.on('disconnect', function(){});
});
server.listen(3000);
```
