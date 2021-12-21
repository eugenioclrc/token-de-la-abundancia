<script>
  import { base } from '$app/paths';
  import { lastToken, wallet, getTokens, contracts, nftAddress, networkDetails } from '../../store/index';

  import { parseEther } from "@ethersproject/units";
  
  let tokens = [];

  $: if($wallet && $lastToken) {
    getTokens(Math.max(0, $lastToken-10), $lastToken + 1).then(resp => {
      tokens = resp.filter(e=> String(e.id) !== '0');
    });
  }

  let loading = false;

  async function join(tokenId) {
    loading = true;
    try {
      const dream = prompt('Cual es tu sueño?');
      const tx = await contracts.telarNFT.mint(tokenId, dream, {value: parseEther("0.025") });
      await tx.wait();
    } catch(err ) {

    }
    loading = false;
  }

</script>
<section class="bg-gray-800 position relative h-72">
</section>
<div class="bg-gray-300 pb-6 mb-8">
  <section class="bg-white  relative -mt-36 mb-36 max-w-4xl mx-auto overflow-auto">
    <div class="w-full overflow-hidden rounded-lg shadow-lg">
    <div class="w-full ">
      <table class="w-full">
        <thead>
          <tr class="text-md font-semibold tracking-wide text-left text-gray-900 bg-gray-100 uppercase border-b border-gray-600">
            <th class="px-4 py-3">tokenId</th>
            <th class="px-4 py-3">Wallet</th>
            <th class="px-4 py-3">Status</th>
            <th class="px-4 py-3">Sueño</th>
          </tr>
        </thead>
        <tbody class="bg-white">
          {#each tokens as token}
            <tr class="text-gray-700">
              <td class="px-4 py-3 text-ms font-semibold border">
                <a href={base+'/app/token?token='+token.id} class="flex hover:underline text-blue-800 font-semibold">{token.id}</a>
              </td>
              <td class="px-4 py-3 border">
                <div class="flex items-center text-sm">
                  <div>
                    <p class="font-semibold text-blue-800">{token.owner.slice(0,4)}...{token.owner.slice(-4)}</p>
                    {#if $networkDetails.chainId == 4}
                      <a href="https://testnets.opensea.io/assets/{$nftAddress}/{token.id}" target="_blank" class="text-blue-800 hover:underline">
                        Opensea
                      </a>
                    {/if}
                  </div>
                </div>
              </td>
              <td class="px-4 py-3 text-xs border">
                {#if token.status_ == 0}
                  <span class="px-2 py-1 font-semibold leading-tight text-red-700 bg-red-100 rounded-sm"> FUEGO </span>
                  <button disabled={loading} on:click={() => join(String(token.id))} class="font-bold rounded bg-gray-200 p-2 hover:font-bold hover:bg-gray-300"
                    class:cursor-not-allowed={loading}>UNIRME!</button>
                {:else if token.status_ == 1}
                  <span class="px-2 py-1 font-semibold leading-tight text-white bg-blue-600 rounded-sm"> AIRE </span>
                {:else if token.status_ == 2}
                  <span class="px-2 py-1 font-semibold leading-tight text-green-700 bg-green-100 rounded-sm"> TIERRA </span>
                {:else if token.status_ == 3}
                  <span class="px-2 py-1 font-semibold leading-tight text-blue-700 bg-blue-100 rounded-sm"> AGUA </span>
                {/if}
              </td>
              <td class="px-4 py-3 text-sm border w-1/3">
                {token.detail}
              </td>
            </tr>
          {/each}
   
        </tbody>
      </table>
    </div>
  </div>

  
  </section>
</div>