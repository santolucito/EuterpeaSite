<apply template="base">

  <ifLoggedIn>

    <p>Congrats!  You're logged in as '<loggedInUser/>'</p>

    <p>Your Stocks...</p>

    <allStocks>
       <p>You have <stockNumber/> shares of <stockTicker/></p>
    </allStocks>

    <p><a href="/logout">Logout</a></p>
  </ifLoggedIn>

  <ifLoggedOut>
    <apply template="_login"/>
  </ifLoggedOut>

</apply>
